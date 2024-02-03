class Summary::Shop < Summary
  TOP_SHOPS_LIMIT = 100
  SQL_QUERY = "shop, COUNT(payment_date) AS payment_count, SUM(revenue) AS total_revenue, MAX(payment_date) AS last_payment_date".freeze

  def summarize
    summary = {}

    summarized_shop_data.each do |shop, data|
      summary[shop] = {
        payments: data["payment_count"],
        revenue: data["total_revenue"],
        last_payment: data["last_payment_date"]
      }
    end

    summary
  end

  private

  def summarized_shop_data(page: 1, per_page: TOP_SHOPS_LIMIT)
    offset = (page - 1) * per_page
    result = payments
      .select(SQL_QUERY)
      .group(:shop)
      .order("total_revenue DESC")
      .offset(offset)
      .limit(per_page)

    result.each_with_object({}) do |record, hash|
      hash[record.shop] = record.attributes.except("shop")
    end
  end
end
