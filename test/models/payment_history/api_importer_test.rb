require "test_helper"

class PaymentHistory::ApiImporterTest < ActiveSupport::TestCase
  setup do
    @user = users(:regular)
  end

  test "new" do
    importer = PaymentHistory::ApiImporter.new(user: @user)

    assert importer.user == @user
  end

  test "import!" do
    importer = PaymentHistory::ApiImporter.new(user: @user)

    ShopifyPartnerAPI.client.expects(:query).with(
      Graphql::TransactionsQuery,
      variables: {
        createdAtMin: @user.calculate_from_date.iso8601,
        cursor: ""},
      context: {
        access_token: @user.partner_api_access_token,
        organization_id: @user.partner_api_organization_id
      }
    ).returns(fixture_graphql_file_for("recurring.json"))

    assert_difference "PaymentHistory.count", 1 do
      importer.import!
    end

    last_payment = PaymentHistory.last
    assert last_payment.valid?
    assert last_payment.user == @user
    assert last_payment.app_title = "Recurring Subscription App"
    assert last_payment.revenue == 23.81
    assert last_payment.charge_type == "recurring_revenue"
    assert last_payment.payment_date == Date.parse("2023-02-01")
    assert last_payment.shop == "recurring.myshopify.com"
    # Not possible to get this data from the API
    # assert last_payment.shop_country == "US"
  end

  test "import! fails with no api credentials" do
    @user.partner_api_access_token = nil
    @user.partner_api_organization_id = nil

    importer = PaymentHistory::ApiImporter.new(user: @user)

    assert_raise StandardError do
      importer.import!
    end
  end

  private

  def fixture_graphql_file_for(filename)
    # Requires json file key names to be in underscore format (not camelCase)
    json = File.read(Rails.root.join("test", "fixtures", "files", "graphql", filename))
    JSON.parse(json, object_class: OpenStruct)
  end
end
