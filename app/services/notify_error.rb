class NotifyError
  attr_reader :exception, :args

  def self.call(exception:, args: {})
    new(exception: exception, args: args).notify
  end

  def initialize(exception:, args: {})
    @exception = exception
    @args = args
  end

  def notify
    Airbrake.notify(exception, parameters: { args: args })
  end
end
