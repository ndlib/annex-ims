class DestroyRequest
  attr_reader :request, :user

  def self.call(request, user)
    new(request, user).destroy
  end

  def initialize(request, user)
    @request = request
    @user = user
  end

  def destroy
    status = request.destroy!
    ActivityLogger.remove_request(request: request, user: user)
    status
  end
end
