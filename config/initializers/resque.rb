Resque.redis = if ENV["REDIS_URL"].blank?
  Redis.new(host: "localhost", port: "6379")
else
  Redis.new(url: ENV["REDIS_URL"], ssl_params: {verify_mode: OpenSSL::SSL::VERIFY_NONE})
end
Resque.logger = Logger.new(STDOUT)
Resque.logger.level = Logger::INFO
