module PartnerMetrics
  module Mcp
    class MetricsSerializer
      CHARGE_TYPES = {
        "overview" => nil,
        "recurring_revenue" => "recurring_revenue",
        "onetime_revenue" => "onetime_revenue",
        "affiliate_revenue" => "affiliate_revenue"
      }.freeze

      class << self
        def tiles(user:, params:)
          normalized_params = normalize_tile_params(params)
          filter = Metric::TilesFilter.new(user: user, params: normalized_params)

          {
            filters: {
              app: filter.app,
              chart: filter.chart,
              date: filter.date.iso8601,
              period: filter.period,
              charge_type: normalized_params[:charge_type] || "overview"
            },
            has_metrics: filter.has_metrics?,
            app_titles: filter.app_titles.sort,
            period_options: Metric::PERIODS,
            charge_type_options: CHARGE_TYPES.keys,
            selected_tile: tile(filter.selected_tile, include_chart_data: true),
            tiles: filter.tiles.map { |tile_presenter| tile(tile_presenter) }
          }
        end

        def monthly_summary(user:, selected_app: nil)
          summaries = Summary::Monthly.new(user: user, selected_app: selected_app).summarize

          {
            filters: {selected_app: selected_app},
            months: summaries.map do |month, values|
              {
                month: month.to_date.iso8601,
                payments: scalar(values[:payments]),
                revenue: scalar(values[:revenue]),
                revenue_per_payment: scalar(values[:revenue_per_payment]),
                revenue_churn: scalar(values[:revenue_churn]),
                user_churn: scalar(values[:user_churn])
              }
            end
          }
        end

        def shop_summary(user:, selected_app: nil)
          summaries = Summary::Shop.new(user: user, selected_app: selected_app).summarize

          {
            filters: {selected_app: selected_app},
            shops: summaries.map do |shop, values|
              {
                shop: shop,
                payments: scalar(values[:payments]),
                revenue: scalar(values[:revenue]),
                last_payment: values[:last_payment]&.to_date&.iso8601
              }
            end
          }
        end

        def options(user:)
          {
            charge_types: CHARGE_TYPES.keys,
            periods: Metric::PERIODS,
            app_titles: user.metrics.distinct.pluck(:app_title).compact.sort,
            newest_metric_date: user.newest_metric_date&.iso8601,
            default_date: user.newest_metric_date_or_today.iso8601
          }
        end

        private

        def normalize_tile_params(params)
          params = params.to_h.symbolize_keys
          charge_type = params[:charge_type].presence || "overview"
          raise ArgumentError, "charge_type must be one of: #{CHARGE_TYPES.keys.join(", ")}" unless CHARGE_TYPES.key?(charge_type)

          if params[:period].present? && !Metric::PERIODS.include?(params[:period].to_i)
            raise ArgumentError, "period must be one of: #{Metric::PERIODS.join(", ")}"
          end

          {
            app: params[:app].presence,
            chart: params[:chart].presence,
            date: params[:date].presence,
            period: params[:period].presence,
            charge_type: CHARGE_TYPES.fetch(charge_type)
          }
        end

        def tile(tile_presenter, include_chart_data: false)
          data = {
            handle: tile_presenter.handle.to_s,
            title: tile_presenter.handle.to_s.humanize,
            display: tile_presenter.display.to_s,
            calculation: tile_presenter.calculation.to_s,
            width: tile_presenter.width.to_s,
            is_yearly_revenue: tile_presenter.is_yearly_revenue,
            positive_change_is_good: tile_presenter.positive_change_is_good,
            current_value: scalar(tile_presenter.current_value),
            previous_value: scalar(tile_presenter.previous_value),
            change_percent: scalar(tile_presenter.change),
            average_value: scalar(tile_presenter.average_value)
          }

          data[:chart_data] = chart_data(tile_presenter.chart_data) if include_chart_data
          data
        end

        def chart_data(series)
          series.map do |entry|
            {
              name: entry[:name].to_s,
              data: entry[:data].to_h.transform_keys { |date| date.to_date.iso8601 }.transform_values { |value| scalar(value) }
            }
          end
        end

        def scalar(value)
          return nil if value.nil?
          return value.iso8601 if value.respond_to?(:iso8601)
          return value.to_s("F") if value.is_a?(BigDecimal)
          return value.finite? ? value : value.to_s if value.is_a?(Float)

          value
        end
      end
    end
  end
end
