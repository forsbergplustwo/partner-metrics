require "zip"
require "csvreader"

class Import::Adaptor::CsvFile
  BATCH_SIZE = 500

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

  def initialize(import:, created_at_min:)
    @import = import
    @created_at_min = created_at_min

    @temp_files = {}
  end

  def fetch_payments
    Enumerator.new do |enum|
      CsvHashReader.foreach(prepared_csv_file, **CSV_READER_OPTIONS) do |csv_row|
        parsed_row = parse(csv_row)
        break if parsed_row[:payment_date] <= @created_at_min

        enum.yield parsed_row
      end
    end
  ensure
    Rails.logger.info "Closing and unlinking temp files"
    close_and_unlink_temp_files
  end

  def batch_size
    BATCH_SIZE
  end

  private

  def parse(csv_row)
    {
      charge_type: charge_type(csv_row),
      payment_date: payment_date(csv_row),
      revenue: revenue(csv_row),
      app_title: app_title(csv_row),
      shop: shop(csv_row),
      shop_country: shop_country(csv_row)
    }
  end

  def charge_type(csv_row)
    CSV_REVENUE_TYPES.find { |_key, value| value.include?(csv_row[:charge_type]) }&.first
  end

  def payment_date(csv_row)
    Date.parse(csv_row[:charge_creation_time])
  end

  def revenue(csv_row)
    csv_row[:partner_share]&.to_f || 0.0
  end

  def app_title(csv_row)
    csv_row[:app_title].presence || Payment::UNKNOWN_APP_TITLE
  end

  def shop(csv_row)
    csv_row[:shop]
  end

  def shop_country(csv_row)
    csv_row[:shop_country]
  end

  def prepared_csv_file
    file = @import.payouts_file
    if zipped?(file.content_type)
      extracted_zip_file(ActiveStorage::Blob.service.path_for(file.key))
    else
      ActiveStorage::Blob.service.path_for(file.key)
    end
  end

  def zipped?(content_type)
    content_type.include?("application/zip")
  end

  def extracted_zip_file(zipped_file)
    @temp_files[:csv] = Tempfile.new("csv", encoding: "UTF-8")
    Zip.on_exists_proc = true
    Zip.continue_on_exists_proc = true
    Zip::File.open(zipped_file) do |zip_file|
      zip_file.each do |entry|
        entry.extract(@temp_files[:csv])
      end
    end
    @temp_files[:csv]
  end

  def close_and_unlink_temp_files
    @temp_files.each_value do |file|
      file.close
      file.unlink
    end
  end
end
