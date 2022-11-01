if ENV["REDIS_URL"]
  $redis = Resque.redis = Redis.new(url: ENV["REDISCLOUD_URL"], ssl_params: {verify_mode: OpenSSL::SSL::VERIFY_NONE})
end
