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
    request.destroy!
    LogActivity.call(request, "Destroyed", nil, Time.now, user)
  end
end
