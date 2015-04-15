Airbrake.configure do |config|
  config.api_key = 'beeaf75c8d19bd52091203abe742c115'
  config.host    = 'errbit.library.nd.edu'
  config.port    = 443
  config.secure  = config.port == 443
end
