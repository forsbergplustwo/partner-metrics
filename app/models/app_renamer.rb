# frozen_string_literal: true

class AppRenamer
  def initialize(user:, from:, to:)
    @user = user
    @from = from
    @to = to
  end

  def rename
    return false unless valid?

    rename_metrics
    rename_payments
    true
  end

  private

  def rename_metrics
    @user.metrics.where(app_title: @from).update_all(app_title: @to) # rubocop:disable Rails/SkipsModelValidations -- bulk rename skips callbacks on purpose
  end

  def rename_payments
    @user.payments.where(app_title: @from).update_all(app_title: @to) # rubocop:disable Rails/SkipsModelValidations -- bulk rename skips callbacks on purpose
  end

  def valid?
    @from.present? && @to.present? && @from != @to
  end
end
