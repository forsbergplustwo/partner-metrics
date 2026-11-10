class ApplicationController < ActionController::Base
  # Allow browsers natively supporting webp, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  protect_from_forgery with: :exception

  def after_sign_in_path_for(resource)
    metrics_path
  end
end
