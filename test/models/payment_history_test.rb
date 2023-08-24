require "test_helper"

class PaymentHistoryTest < ActiveSupport::TestCase

  test "default_start_date" do
    PaymentHistory.default_start_date == 4.years.ago.to_date
  end
end
