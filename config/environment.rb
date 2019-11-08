# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

SunspotConfig = Sunspot::Rails::Configuration.new
Sunspot.config.solr.url = "http://#{SunspotConfig.hostname}:#{SunspotConfig.port}#{SunspotConfig.path}"
