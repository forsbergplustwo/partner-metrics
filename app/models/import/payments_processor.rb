class Import::PaymentsProcessor
  def initialize(import:)
    @import = import
    @user = import.user
    @import_payments_after_date = import.import_payments_after_date
    @source_adaptor = import.source_adaptor.new(import: import, import_payments_after_date: @import_payments_after_date)
  end

  def import!
    @user.clear_old_payments!(after: @import_payments_after_date)
    import_new_payments
  rescue => error
    @import&.fail
    raise error
  end

  private

  def import_new_payments
    fetched_payments.each_slice(@source_adaptor.batch_size) do |batch|
      payments = []
      batch.each do |transaction|
        next if transaction[:payment_date] <= @import_payments_after_date
        next if transaction[:charge_type].nil?
        next if transaction[:shop].nil?
        next if transaction[:revenue].zero?

        payments << new_payment(transaction)
      end

      Payment.import!(payments.compact, validate: false, no_returning: true) if payments.present?
      @import.touch
    end
  end

  def fetched_payments
    @source_adaptor.fetch_payments
  end

  def new_payment(payment)
    payment[:charge_type] = adjust_usage_charge_type(payment) if payment[:charge_type] == "usage_revenue"
    # Note to self: Do not refactor to payment.new objects
    # It grows memory like crazy when processing large files
    {
      user_id: @user.id,
      import_id: @import.id,
      payment_date: payment[:payment_date],
      charge_type: payment[:charge_type],
      revenue: payment[:revenue],
      app_title: payment[:app_title],
      shop: payment[:shop],
      shop_country: payment[:shop_country]
    }
  end

  def adjust_usage_charge_type(charge_type)
    (@user.count_usage_charges_as_recurring == true) ? "recurring_revenue" : "onetime_revenue"
  end
end
