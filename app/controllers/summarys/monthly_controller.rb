# frozen_string_literal: true

module Summarys
  class MonthlyController < SummarysController
    def index
      @selected_app = summary_params[:selected_app]
      @summaries = Summary::Monthly.new(user: current_user, selected_app: @selected_app).summarize

      render("summarys/index")
    end
  end
end
