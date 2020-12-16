# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path("../config/application", __FILE__)

Rails.application.load_tasks

# this task will get called before resque:pool:setup
# and preload the rails environment in the pool manager
#
require "resque/pool/tasks"
task "resque:pool:setup" do
  # close any sockets or files in pool manager
  ActiveRecord::Base.connection.disconnect!
  Resque::Pool.after_prefork do
    ActiveRecord::Base.establish_connection
  end
end
