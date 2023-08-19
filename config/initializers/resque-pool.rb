WORKER_CONCURRENCY = Integer(ENV["WORKER_CONCURRENCY"] || 3)
RESQUE_POOL_CONFIG = {"*" => WORKER_CONCURRENCY}

File.write(Rails.root.join("config/resque-pool.yml"), RESQUE_POOL_CONFIG.to_yaml)
