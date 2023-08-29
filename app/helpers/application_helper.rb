module ApplicationHelper
  def icon_source_url(name)
    Polaris::ViewComponents::Engine.root.join("app", "assets", "icons", "polaris", "#{name}.svg")
  end
end
