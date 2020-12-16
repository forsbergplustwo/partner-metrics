WORKER_CONCURRENCY = Integer(ENV["WORKER_CONCURRENCY"] || 3)
RESQUE_POOL_CONFIG = {"*" => WORKER_CONCURRENCY}

File.open(Rails.root.join("config/resque-pool.yml"), "w") { |f| f.write RESQUE_POOL_CONFIG.to_yaml }
