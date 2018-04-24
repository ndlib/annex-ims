source "https://rubygems.org"

group :application do
  # Bundle edge Rails instead: gem "rails", github: "rails/rails"
  gem "rails", "~> 4.2.7.1"
  # Use postgresql as the database for Active Record
  gem "pg", "~> 0.18.2"
  # Use SCSS for stylesheets
  gem "sass-rails", "~> 5.0"
  # Use Uglifier as compressor for JavaScript assets
  gem "uglifier", ">= 1.3.0"
  # Use CoffeeScript for .coffee assets and views
  gem "coffee-rails", "~> 4.1.0"
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem "therubyracer", platforms: :ruby

  # Use jquery as the JavaScript library
  gem "jquery-rails"
  # Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
  gem "turbolinks"
  # Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
  gem "jbuilder", "~> 2.0"

  # Use Haml for markup because I like it.
  gem "haml-rails"

  # Use Bootstrap because I"m not a designer
  gem "bootstrap-sass", "~> 3.3.5"
  gem "autoprefixer-rails"

  # Someone already Rails-ified a nice datepicker for Bootstrap
  gem "bootstrap-datepicker-rails"

  # Someone else Rails-ified Datatables
  gem "jquery-datatables-rails", "~> 3.1.1"

  # Devise for authentication, CAS for use in ND
  gem "devise"
  gem "devise_cas_authenticatable"

  # For consuming the API for items
  gem "faraday"
  gem "faraday_middleware"
  gem "multi_xml"

  # For item search
  gem "sunspot_rails", :git => "https://github.com/sunspot/sunspot.git"
  gem "progress_bar" # Because I want to see progress of reindexing

  # For paginating results
  gem "kaminari"

  gem "sneakers"

  # New Relic
  gem "newrelic_rpm"

  # Bug in rake
  gem 'rake', '< 11.0'
end

# For cron tasks
gem "whenever", require: false

# For Errbit
gem "airbrake"

group :deployment do
  # Use Capistrano for deployment
  gem "capistrano", "~> 3.4"
  gem "capistrano-rails", "~> 1.1"
  gem "capistrano-maintenance", "~> 1.0"
end

group :development, :test, :staging do
  # For realistic fake data
  gem "faker", "~> 1.4"
end

group :development, :test do
  gem "spring-commands-rspec"
  gem "hesburgh_infrastructure", github: "ndlib/hesburgh_infrastructure"
  gem "guard", "2.6.1"
  gem "guard-bundler", "2.0.0"
  gem "guard-coffeescript", "1.4.0"
  gem "guard-rails", "0.6.0"
  gem "guard-rspec", "4.3.1"
  gem "guard-spring", "0.0.4"
  gem "guard-sunspot", github: "ndlib/guard-sunspot"

  gem "coveralls", require: false

  # Call "byebug" anywhere in the code to stop execution and get a debugger console
  gem "byebug"

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem "web-console", "~> 2.0"

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem "spring"

  # We test with Rspec
  gem "rspec-rails", "~> 3.0"

  # For mocking up objects
  gem "factory_girl_rails", "~> 4.5"

  # For cleaning up the test database
  gem "database_cleaner", "~> 1.3"

  # Feature testing
  gem "capybara", "~> 2.4"
  gem "capybara-webkit"

  # So staging etc can use stand alone Solr
  gem "sunspot_solr", :git => "https://github.com/sunspot/sunspot.git"

  # For serving up ssl
  gem "thin"

  gem "rails-erd"

  # bundle exec rake doc:rails generates the API under doc/api.
  gem "sdoc", "~> 0.4.0"
end

group :test do
  # For mocking up APIs
  gem "webmock"
  gem "shoulda-matchers"

  # rspec matchers for sunspot
  gem "sunspot_matchers"
end

group :development do
  # Simple generators for layouts
  gem "rails_layout"

  # Better error page
  gem "better_errors"
  gem "binding_of_caller"
  gem 'quiet_assets'
end
