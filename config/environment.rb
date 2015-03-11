# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

SunspotConfig = Sunspot::Rails::Configuration.new
Sunspot.config.solr.url = "http://#{SunspotConfig.hostname}:#{SunspotConfig.port}/#{SunspotConfig.path}"
