require "zip"
require "csvreader"

class Import::Adaptor::CsvFile
  BATCH_SIZE = 1000
  MAX_HISTORY = 12.years

  CSV_READER_OPTIONS = {
    header_converters: :symbol,
    encoding: "UTF-8"
  }.freeze

  CSV_YEARLY_IDENTIFIER = "yearly".freeze

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

  def initialize(import:, import_payments_after_date:)
    @import = import
    @import_payments_after_date = import_payments_after_date

    @temp_files = {}
    @prepared_csv_file = prepared_csv_file
  end

  def fetch_payments
    Enumerator.new { |main_enum| stream_payments(main_enum) }
  end

  def batch_size
    BATCH_SIZE
  end

  private

  def stream_payments(main_enum)
    CsvHashReader.foreach(@prepared_csv_file, **CSV_READER_OPTIONS) do |csv_row|
      parsed_row = parse(csv_row)
      break if parsed_row[:payment_date] <= @import_payments_after_date

      main_enum.yield parsed_row
    end
  ensure
    close_and_unlink_temp_files
  end

  def parse(csv_row)
    {
      charge_type: charge_type(csv_row),
      payment_date: payment_date(csv_row),
      revenue: revenue(csv_row),
      is_yearly_revenue: is_yearly_revenue(csv_row),
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

  def is_yearly_revenue(csv_row)
    csv_row[:charge_type].to_s.include?(CSV_YEARLY_IDENTIFIER)
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
    return @prepared_csv_file if @prepared_csv_file

    file = @import.payouts_file

    @temp_files[:raw] = Tempfile.new("raw")
    @temp_files[:raw].write(file.download.force_encoding("UTF-8"))
    @temp_files[:raw].rewind

    if zipped?(file.content_type)
      extracted_zip_file(@temp_files[:raw].path)
    else
      @temp_files[:raw].path
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
