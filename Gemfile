source "https://rubygems.org"
ruby "2.6.8"

gem "activerecord-import"
gem "aws-sdk", "~> 2"
gem "bootstrap-datepicker-rails"
gem "bootstrap-sass"
gem "bootstrap-select-rails", "~> 1.12.0"
gem "chartkick"
gem "coffee-rails", "~> 4.0.0"
gem "convenient_grouper"
gem "devise"
gem "devise-bootstrap-views"
gem "font-awesome-rails", "~> 4.7.0"
gem "font-awesome-sass", "~> 4.7.0"
gem "groupdate"
gem "high_voltage"
gem "intercom-rails"
gem "jbuilder", "~> 2.0"
gem "jquery-rails"
gem "jquery-tablesorter"
gem "pg", "< 1.0.0"
gem "pkg-config"
gem "rack-timeout", require: "rack/timeout/base"
gem "rails", "~> 4.2"
gem "redis", "~> 4.0"
gem "remotipart", "~> 1.0"
gem "resque"
gem "resque-pool"
gem "resque-web", require: "resque_web"
gem "rubyzip"
gem "sass-rails", "~> 4.0.3"
gem "sdoc", "~> 0.4.0", group: :doc
gem "csvreader"
gem "spring", group: :development
gem "uglifier", ">= 1.3.0"
gem "unicorn"
gem "graphql-client"

group :development, :test do
  gem "puma"
  gem "foreman"

  # Code analysis / linters
  gem "brakeman"
  gem "bullet"
  gem "bundle-audit"
  gem "lefthook"
  gem "rubocop"
  gem "rubocop-rails"
  gem "rubocop-performance"
  gem "rubocop-thread_safety"
end

group :development do
  # gem 'better_errors'
  gem "binding_of_caller"
  gem "hub", require: nil
  gem "quiet_assets"
  gem "rails_layout"
end
group :production do
  gem "rails_12factor"
end

gem "graphiql-rails", group: :development
