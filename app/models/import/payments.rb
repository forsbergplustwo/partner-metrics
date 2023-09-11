class Import::Payments
  def initialize(import:)
    @import = import
    @user = @import.user
    @created_at_min = @user.calculate_from_date
    @source_adaptor = @import.source_adaptor.new(import: @import, created_at_min: @created_at_min)
    @batch_of_payments = []
  end

  def import!
    @user.clear_old_payments!
    import_new_payments
  rescue => error
    @import&.failed!
    raise error
  end

  private

  def import_new_payments
    fetched_payments.each_slice(@source_adaptor.batch_size) do |batch|
      payments = batch.map do |transaction|
        break if transaction[:payment_date] <= @created_at_min
        next if transaction[:charge_type].nil?
        next if transaction[:shop].nil?
        next if transaction[:revenue].zero?

        new_payment(transaction)
      end.compact

      @batch_of_payments.concat(payments)
      Payment.import!(@batch_of_payments, validate: false, no_returning: true)
      @import.touch
      @batch_of_payments.clear
    end
  end

  private

  def fetched_payments
    @source_adaptor.fetch_payments
  end

  def new_payment(payment)
    payment[:charge_type] = adjust_usage_charge_type(payment) if payment[:charge_type] == "usage_revenue"

    @user.payments.new(
      import: @import,
      payment_date: payment[:payment_date],
      charge_type: payment[:charge_type],
      revenue: payment[:revenue],
      app_title: payment[:app_title],
      shop: payment[:shop],
      shop_country: payment[:shop_country]
    )
  end

  def adjust_usage_charge_type(charge_type)
    (@user.count_usage_charges_as_recurring == true) ? "recurring_revenue" : "onetime_revenue"
  end
end
