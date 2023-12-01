Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV["REDIS_URL"],
    ssl_params: {verify_mode: OpenSSL::SSL::VERIFY_NONE}
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV["REDIS_URL"],
    ssl_params: {verify_mode: OpenSSL::SSL::VERIFY_NONE}
  }
end

# TODO: Remove this once turbo-rails v8 is stable
# Required due to: https://github.com/hotwired/turbo-rails/pull/525/files
Sidekiq.strict_args!(false)
