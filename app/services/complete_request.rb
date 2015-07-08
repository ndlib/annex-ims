class CompleteRequest
  attr_reader :request, :user

  def self.call(request:, user:)
    new(request: request, user: user).complete!
  end

  def initialize(request:, user:)
    @request = request
    @user = user
  end

  def complete!
    unless @request.completed?
      @request.completed!
      ActivityLogger.fill_request(user: user, request: request)
    end
  end
end
