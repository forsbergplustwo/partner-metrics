module ApplicationHelper
  def resource_name_for(klass, pluralize = false)
    klass.name.pluralize(pluralize ? 2 : 1).downcase
  end

  def status_badge(status)
    badge_status = case status
    when "complete" then :success
    when "draft", "importing", "calculating" then :info
    when "cancelled" then :warning
    when "failed" then :attention
    else
      :default
    end
    badge_progress = case status
    when "scheduled" then :incomplete
    when "calculating", "importing", "failed" then :partially_complete
    when "complete", "cancelled" then :complete
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
