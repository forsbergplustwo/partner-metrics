require "test_helper"

class PaymentHistory::CsvImporterTest < ActiveSupport::TestCase

  setup do
    @user = users(:regular)
    @filename = "filename.zip"
  end

  test "new" do
    @user = users(:regular)
    @filename = "filename.zip"

    @importer = PaymentHistory::CsvImporter.new(user: @user, filename: @filename)

    assert @importer.user == @user
    assert @importer.filename == @filename
    assert @importer.calculate_from_date == @user.calculate_from_date
  end

  # test "import" do
  # end
end
