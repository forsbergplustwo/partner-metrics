source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

# Backend
gem "rails", "~> 7.0.5"
gem "pg", "~> 1.1"
gem "puma", "~> 6.0"
gem "redis", "~> 5.0"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "bootsnap", require: false
gem "sidekiq"
gem "graphql-client"
gem "aws-sdk-s3", require: false
gem "rack-timeout", require: "rack/timeout/base"
gem "csvreader"
gem "activerecord-import"

# Frontend
gem "sprockets-rails"
gem "jsbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "devise"

# Charting + Metrics Display
gem "chartkick"
gem "groupdate"
gem "convenient_grouper"

group :development, :test do
  gem "debug", platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem "web-console"
  gem "pry-rails"
  gem "foreman"
  gem "standard"
  gem "standard-rails"
  gem "standard-minitest"
  gem "standard-thread_safety"
  gem "hotwire-livereload"
  gem "letter_opener"
  gem "http_logger"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end
