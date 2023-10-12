module ImportsHelper
  def secondary_import_actions(import)
    actions = []
    if import.retriable?
      actions << {
        content: t("actions.retry", resource: resource_name_for(Import)),
        url: import_retry_path(import),
        data: {
          turbo_method: "post"
        }
      }
    end
    actions << {
      content: t("actions.delete", resource: resource_name_for(Import)),
      destructive: true,
      data: {
        controller: "polaris",
        target: "#destroy-modal",
        action: "polaris#openModal"
      }
    }
  end

  def metrics_date_range_text(import)
    if import.metrics.empty?
      t("imports.no_metrics")
    else
      "#{import.metrics.minimum(:metric_date)} - #{import.metrics.maximum(:metric_date)}"
    end
  end
end
