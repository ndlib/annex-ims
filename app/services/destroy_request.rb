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
    LogActivity.call(request, "Removed", nil, Time.now, user)
    status
  end
end
