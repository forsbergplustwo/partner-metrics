Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout, service_timeout: 27
