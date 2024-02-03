class Summarys::ShopController < SummarysController
  def index
    @selected_app = summary_params[:selected_app]
    @page = params[:page] || 1
    @per_page = params[:per_page] || Summary::Shop::TOP_SHOPS_LIMIT
    @summaries = Summary::Shop.new(user: current_user, selected_app: @selected_app).summarize(page: @page.to_i, per_page: @per_page.to_i)

    render "summarys/index"
  end
end
