web: bundle exec unicorn -p $PORT -c ./config/unicorn.rb
worker: bundle exec rake environment resque:pool
release: bundle exec rake db:migrate
