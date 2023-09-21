module ImportsHelper
  def metrics_date_range_text(import)
    if import.metrics.empty?
      t("imports.no_metrics")
    else
      "#{import.metrics.minimum(:metric_date)} - #{import.metrics.maximum(:metric_date)}"
    end
  end
end
