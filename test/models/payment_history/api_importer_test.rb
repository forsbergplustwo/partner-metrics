require "test_helper"

class PaymentHistory::ApiImporterTest < ActiveSupport::TestCase
  setup do
    @user = users(:regular)
  end

  test "new" do
    importer = PaymentHistory::ApiImporter.new(user: @user)

    assert importer.user == @user
  end

  # test "import!" do
  #   # TODO: Work out how to stub the API call
  #   importer = PaymentHistory::ApiImporter.new(user: @user)

  #   assert_difference "PaymentHistory.count", X do
  #     importer.import!
  #   end
  # end

  test "import! fails with no api credentials" do
    importer = PaymentHistory::ApiImporter.new(user: @user)

    assert_raise StandardError do
      importer.import!
    end
  end

end
