module ApplicationHelper
  def resource_name_for(klass, pluralize = false)
    klass.model_name.human.pluralize(pluralize ? 2 : 1).downcase
  end

  def status_badge(status)
    badge_status = case status
    when "complete", "valid" then :success
    when "draft", "importing", "calculating" then :info
    when "cancelled", "pending_validation" then :warning
    when "failed", "invalid" then :attention
    else
      :default
    end
    badge_progress = case status
    when "scheduled", "invalid" then :incomplete
    when "calculating", "importing", "failed", "pending_validation" then :partially_complete
    when "complete", "cancelled", "valid" then :complete
    else
      :default
    end

    polaris_badge(status: badge_status, progress: badge_progress) do
      t("statuses.#{status}")
    end
  end

  def icon_source_url(name)
    Polaris::ViewComponents::Engine.root.join("app", "assets", "icons", "polaris", "#{name}.svg")
  end
end
