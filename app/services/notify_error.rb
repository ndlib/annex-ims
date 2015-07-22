module NotifyError
  def self.call(exception:, parameters: {}, component: nil, action: nil)
    Airbrake.notify(exception,
                    component: component,
                    action: action,
                    parameters: parameters,
                    cgi_data: environment_info)
  end

  private

  def self.environment_info
    ENV.reject do |k|
      Airbrake.configuration.rake_environment_filters.include? k
    end
  end
end
