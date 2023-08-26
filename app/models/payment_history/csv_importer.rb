require "zip"

class PaymentHistory::CsvImporter

  SAVE_EVERY_N_ROWS = 1000

  CSV_READER_OPTIONS = {
    converters: :all,
    header_converters: :symbol,
    encoding: "UTF-8"
  }.freeze

  CSV_REVENUE_TYPES = {
    "recurring_revenue" => [
      "RecurringApplicationFee",
      "Recurring application fee",
      "App sale – recurring",
      "App sale – subscription",
      "App sale – 30-day subscription",
      "App sale – yearly subscription"
    ],
    "onetime_revenue" => [
      "OneTimeApplicationFee",
      "ThemePurchaseFee",
      "One time application fee",
      "Theme purchase fee",
      "App sale – one-time",
      "Service sale"
    ],
    "affiliate_revenue" => [
      "AffiliateFee",
      "Affiliate fee",
      "Development store referral commission",
      "Affiliate referral commission",
      "Shopify Plus referral commission"
    ],
    "refund" => [
      "Manual",
      "ApplicationDowngradeAdjustment",
      "ApplicationCredit",
      "AffiliateFeeRefundAdjustment",
      "Application credit",
      "Application downgrade adjustment",
      "Application fee refund adjustment",
      "App credit",
      "App refund",
      "App credit refund",
      "Development store commission adjustment",
      "Payout correction",
      "App downgrade",
      "Service refund"
    ],
    "usage_revenue" => [
      "App sale – usage",
      "Usage application fee",
      "AppUsageSale"
    ]
  }.freeze

  def initialize(user:, filename:)
    @user = user
    @filename = filename
    @temp_files = {}
    @rows_processed_count = 0
    @batch_of_payments = []
  end

  attr_accessor :user, :filename, :temp_files

  def import!
    prepare_csv_file
    user.clear_old_payments
    import_new_payments
  rescue => error
    handle_import_error(error)
    raise error
  ensure
    close_and_unlink_temp_files
  end

  private

  def prepare_csv_file
    file = fetch_from_s3(filename)
    temp_files[:csv] = if zipped?(filename)
      extracted_zip_file(file)
    else
      file
    end
  end

  def import_new_payments
    # Loops through CSV file, saving in chunks of N rows
    CsvHashReader.foreach(temp_files[:csv], CSV_READER_OPTIONS) do |csv_row|
      next if irrelevant_row?(csv_row)
      break if row_too_old?(csv_row)

      @batch_of_payments << new_payment(csv_row)

      @rows_processed_count += 1
      if @rows_processed_count % SAVE_EVERY_N_ROWS == 0
        save_and_reset_batch(@batch_of_payments)
        user.update(import: "Importing (#{@rows_processed_count} rows processed)", import_status: 100)
      end
    end
    # Save any remaining rows
    save_and_reset_batch(@batch_of_payments)
  end

  def new_payment(csv_row)
    user.payment_histories.new(
      app_title: csv_row[:app_title].presence || PaymentHistory::UNKNOWN_APP_TITLE,
      charge_type: lookup_charge_type(csv_row),
      shop: csv_row[:shop],
      shop_country: csv_row[:shop_country],
      payment_date: csv_row[:charge_creation_time],
      revenue: csv_row[:partner_share].to_f
    )
  end

  def save_and_reset_batch(payments)
    # Uses "activerecord-import", which is much faster than saving each row individually
    PaymentHistory.import(payments, validate: false, no_returning: true) if payments.present?
    @batch_of_payments = []
  end

  def irrelevant_row?(csv_row)
    csv_row[:charge_creation_time].blank? || csv_row[:partner_share].to_f == 0.0
  end

  def row_too_old?(csv_row)
    csv_row[:charge_creation_time] < user.calculate_from_date.to_s
  end

  def lookup_charge_type(csv_row)
    charge_type = CSV_REVENUE_TYPES.find { |_key, value| value.include?(csv_row[:charge_type]) }&.first
    if charge_type == "usage_revenue"
      charge_type = user.count_usage_charges_as_recurring == true ? "recurring_revenue" : "onetime_revenue"
    end
    charge_type
  end

  def zipped?(filename)
    filename.include?(".zip")
  end

  def fetch_from_s3(filename)
    temp_files[:s3_download] = Tempfile.new("s3_download")
    s3 = Aws::S3::Client.new
    s3.get_object({
      bucket: "partner-metrics",
      key: filename
    },
      target: temp_files[:s3_download].path)
    temp_files[:s3_download]
  end

  def extracted_zip_file(zipped_file)
    temp_files[:unzipped] = Tempfile.new("unzipped", encoding: "UTF-8")
    Zip.on_exists_proc = true
    Zip.continue_on_exists_proc = true
    Zip::File.open(zipped_file.path) do |zip_file|
      zip_file.each do |entry|
        entry.extract(temp_files[:unzipped])
      end
    end
    temp_files[:unzipped]
  end

  # TODO: Create a generic import status class
  def handle_import_error(error)
    user.update(
      import: "Failed",
      import_status: 100,
      partner_api_errors: "Error: #{e.message}"
    )
    # Resque swallows errors, so we need to log them here
    Rails.logger.error("Error importing CSV: #{error.message}")
    Rails.logger.error(error.backtrace.join("\n"))
  end

  def close_and_unlink_temp_files
    temp_files.each_value do |file|
      file.close
      file.unlink if file.is_a?(Tempfile)
    end
  end
end
