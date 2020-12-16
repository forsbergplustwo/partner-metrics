worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 27
preload_app true

before_fork do |server, worker|
  Signal.trap "TERM" do
    puts "Unicorn master intercepting TERM and sending myself QUIT instead"
    Process.kill "QUIT", Process.pid
  end

  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.connection.disconnect!

  if defined?(Resque)
    Resque.redis.quit
    Rails.logger.info("Disconnected from Redis")
  end
end

after_fork do |server, worker|
  Signal.trap "TERM" do
    puts "Unicorn worker intercepting TERM and doing nothing. Wait for master to send QUIT"
  end

  if defined?(Resque)
    Rails.logger.info("Connected to Redis")
  end
end
