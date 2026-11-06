require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PartnerMetrics
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0
    # polaris_view_components 1.1 requires helpers from its autoload path (`require "polaris/view_helper"`).
    config.add_autoload_paths_to_load_path = true

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.active_job.queue_adapter = :sidekiq

    config.active_record.encryption.primary_key = Rails.application.credentials[:active_record_encryption][:primary_key]
    config.active_record.encryption.deterministic_key = Rails.application.credentials[:active_record_encryption][:deterministic_key]
    config.active_record.encryption.key_derivation_salt = Rails.application.credentials[:active_record_encryption][:key_derivation_salt]
    # PartnerApiCredential columns were encrypted under Rails 7.0, which used SHA-1.
    # Rails 7.1+ writes SHA-256; keep SHA-1 as a previous scheme so existing rows decrypt.
    config.active_record.encryption.support_sha1_for_non_deterministic_encryption = true
  end
end
