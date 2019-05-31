# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

require "sunspot_matchers"
require "sunspot_matchers/matchers"
require "sunspot_matchers/sunspot_session_spy"
# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # For Devise testing
  config.include Devise::TestHelpers, type: :controller

  config.include ApiHelper

  config.include SunspotMatchers

  config.before(:each) do |example|
    Sunspot.session = SunspotMatchers::SunspotSessionSpy.new(Sunspot.session)
  end

  # Things fail if tray types are not populated first
  config.before(:all) do
    ah = { trays_per_shelf: 16, height: 8, capacity: 136 }
    al = { trays_per_shelf: 16, height: 7, capacity: 136 }
    bh = { trays_per_shelf: 14, height: 10, capacity: 136 }
    bl = { trays_per_shelf: 14, height: 8, capacity: 136 }
    ch = { trays_per_shelf: 12, height: 12, capacity: 136 }
    cl = { trays_per_shelf: 12, height: 10, capacity: 136 }
    dh = { trays_per_shelf: 10, height: 14, capacity: 136 }
    dl = { trays_per_shelf: 10, height: 12, capacity: 136 }
    eh = { trays_per_shelf: 12, height: 16, capacity: 104 }
    el = { trays_per_shelf: 12, height: 14, capacity: 104 }
    s = { trays_per_shelf: 1, height: 1, capacity: nil, unlimited: true }
    TrayType.create_with(ah).find_or_create_by(code: "AH")
    TrayType.create_with(al).find_or_create_by(code: "AL")
    TrayType.create_with(bh).find_or_create_by(code: "BH")
    TrayType.create_with(bl).find_or_create_by(code: "BL")
    TrayType.create_with(ch).find_or_create_by(code: "CH")
    TrayType.create_with(cl).find_or_create_by(code: "CL")
    TrayType.create_with(dh).find_or_create_by(code: "DH")
    TrayType.create_with(dl).find_or_create_by(code: "DL")
    TrayType.create_with(eh).find_or_create_by(code: "EH")
    TrayType.create_with(el).find_or_create_by(code: "EL")
    TrayType.create_with(s).find_or_create_by(code: "SHELF")
  end
end
