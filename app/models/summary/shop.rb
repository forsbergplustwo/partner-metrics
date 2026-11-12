# frozen_string_literal: true

class Summary::Shop < Summary # rubocop:disable Style/ClassAndModuleChildren -- Summary is a class
  TOP_SHOPS_LIMIT = 100
  SQL_QUERY = "shop, COUNT(payment_date) AS payment_count, SUM(revenue) AS total_revenue, MAX(payment_date) AS last_payment_date"

  def summarize
    summary = {}

    summarized_shop_data.each do |shop, data|
      summary[shop] = {
        payments: data["payment_count"],
        revenue: data["total_revenue"],
        last_payment: data["last_payment_date"],
      }
    end

    summary
  end

  private

  def summarized_shop_data
    result = payments
      .select(SQL_QUERY)
      .group(:shop)
      .order("total_revenue DESC")
      .limit(TOP_SHOPS_LIMIT)

    result.each_with_object({}) do |record, hash|
      hash[record.shop] = record.attributes.except("shop")
    end
  end
end
