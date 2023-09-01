module ApplicationHelper
  def status_badge(status)
    badge_status = case status
    when "complete" then :success
    when "draft", "processing", "calculating" then :info
    when "cancelled" then :warning
    when "failed" then :attention
    else
      :default
    end
    badge_progress = case status
    when "schedulled", "processing" then :incomplete
    when "calculating", "failed", "cancelled" then :partially_complete
    when "complete" then :complete
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
