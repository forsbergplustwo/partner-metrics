require "test_helper"
require "zip"

class PaymentHistory::CsvImporterTest < ActiveSupport::TestCase

  setup do
    @user = users(:regular)
    @filename = "mixed.csv"
  end

  test "new" do
    importer = PaymentHistory::CsvImporter.new(user: @user, filename: @filename)

    assert importer.user == @user
    assert importer.filename == @filename
    assert importer.calculate_from_date == @user.calculate_from_date
  end

  test "can import csv files" do
    file = fixture_csv_file_for(@filename)

    importer = PaymentHistory::CsvImporter.new(user: @user, filename: @filename)
    importer.expects(:fetch_from_s3).returns(file)

    assert_difference "PaymentHistory.count", 8 do
      importer.import!
    end
    assert_correct_last_payment
  end

  test "can import zip files" do
    zip_file = fixture_zip_file_for(@filename)

    importer = PaymentHistory::CsvImporter.new(user: @user, filename: zip_file.path)
    importer.expects(:fetch_from_s3).returns(zip_file)

    assert_difference "PaymentHistory.count", 8 do
      importer.import!
    end
    assert_correct_last_payment
  ensure
    zip_file.close
    zip_file.unlink
  end

  private

  def fixture_csv_file_for(filename)
    File.open(Rails.root.join("test", "fixtures", "files", "payouts", filename))
  end

  def fixture_zip_file_for(filename)
    zip_file = Tempfile.new("#{filename}.zip")
    Zip::File.open(zip_file.path, Zip::File::CREATE) do |zipfile|
      zipfile.add(filename, fixture_csv_file_for(filename))
    end
    zip_file
  end

  def assert_correct_last_payment
    last_payment = PaymentHistory.last
    assert last_payment.valid?
    assert last_payment.user == @user
    assert last_payment.app_title = "Recurring Subscription App"
    assert last_payment.revenue == 23.81
    assert last_payment.charge_type == "recurring_revenue"
    assert last_payment.payment_date == Date.parse("2023-07-01")
    assert last_payment.shop == "monthly.myshopify.com"
    assert last_payment.shop_country == "US"
  end
end
