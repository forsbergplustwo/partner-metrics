class Summary::Monthly < Summary
  MONTHS_TO_SUMMARIZE = 36
  GROUP_OPTIONS = {reverse: true, last: MONTHS_TO_SUMMARIZE}.freeze

  def summarize
    summary = {}

    payments_count.each do |month, count|
      summary[month] ||= {}
      summary[month][:payments] = count
    end

    payments_revenue.each do |month, revenue|
      summary[month] ||= {}
      summary[month][:revenue] = revenue
      summary[month][:revenue_per_payment] = revenue / summary[month][:payments].to_f
    end

    metrics_revenue_churn.each do |month, churn|
      summary[month] ||= {}
      summary[month][:revenue_churn] = churn
    end

    metrics_user_churn.each do |month, churn|
      summary[month] ||= {}
      summary[month][:user_churn] = churn
    end

    summary
  end

  private

  def payments_count
    payments.group_by_month(:payment_date, **GROUP_OPTIONS).count
  end

  def payments_revenue
    payments.group_by_month(:payment_date, **GROUP_OPTIONS).sum(:revenue)
  end

  def metrics_revenue_churn
    metrics.group_by_month(:metric_date, **GROUP_OPTIONS).average(:revenue_churn)
  end

  def metrics_user_churn
    metrics.group_by_month(:metric_date, **GROUP_OPTIONS).average(:shop_churn)
  end
end
