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
    request_copy = request.clone
    request_copy.barcode = request_copy.trans
    status = request.destroy!
    LogActivity.call(request_copy, "Removed", nil, Time.now, user)
    status
  end
end
