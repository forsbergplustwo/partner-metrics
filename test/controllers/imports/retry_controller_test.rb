require "test_helper"

class Imports::RetryControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:regular)
    @import = imports(:failed_shopify_payments_api)
  end

  test "should retry shopify api imports" do
    post import_retry_url(@import)

    assert @import.reload.draft? || @import.reload.scheduled?
    assert_redirected_to import_url(@import)
    assert flash[:notice], "Import being retried."
  end
end
