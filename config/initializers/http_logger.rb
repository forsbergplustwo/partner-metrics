if Rails.env.development?
  require 'http_logger'
  HttpLogger.logger = Rails.logger if defined?(Rails)
  HttpLogger.colorize = true
end
