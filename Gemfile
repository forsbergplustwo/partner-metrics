source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "4.0.9"

# Backend
gem "rails", "~> 8.1.4", ">= 8.1.4.1"
gem "pg", "~> 1.1"
gem "puma", "~> 6.0"
gem "redis", "~> 5.0"
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
gem "bootsnap", require: false
# Rails 8.1 removed the built-in Sidekiq adapter. Sidekiq 7.3.3+ registers it.
gem "sidekiq", ">= 7.3.3"
gem "rack-timeout", require: "rack/timeout/base"
gem "active_storage_validations"
gem "sendgrid-actionmailer"
gem "ostruct" # no longer a default gem in Ruby 4.0; required by activerecord-import 1.x
gem "rubyzip"

# Frontend. Propshaft is the Rails 8 asset pipeline. JS is still bundled with esbuild.
gem "propshaft"
gem "jsbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "devise"
# Keep in step with the polaris-view-components npm package (package.json).
# 1.2+ (floating-ui popovers) hangs the browser in the system tests.
gem "polaris_view_components", "~> 1.1.0"

# Charting + Metrics Display
gem "chartkick"
gem "groupdate"
gem "convenient_grouper"
gem "prophet-rb"

# Importing
gem "csvreader"
gem "activerecord-import"
gem "graphql-client"
gem "aws-sdk-s3", require: false

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
  gem "mocha"
end
