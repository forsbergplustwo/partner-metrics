Resque.redis = $redis
Resque.logger = Logger.new(STDOUT)
Resque.logger.level = (Rails.env.production? ? Logger::DEBUG : Logger::INFO)
