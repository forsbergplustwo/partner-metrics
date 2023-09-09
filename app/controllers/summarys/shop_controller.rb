class Summarys::ShopController < SummarysController
  def index
    @selected_app = summary_params[:selected_app]
    @summaries = Summary::Shop.new(user: current_user, selected_app: @selected_app).summarize

    render "summarys/index"
  end
end
