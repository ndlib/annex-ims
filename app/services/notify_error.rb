module NotifyError
  def self.call(exception:, args: {})
    Airbrake.notify(exception, parameters: { args: args })
  end
end
