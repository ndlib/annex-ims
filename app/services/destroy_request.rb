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

  def self.shelve_trays(shelf, user)
    shelf.trays.each do |tray|
      ShelveTray.call(tray, user)
    end
  end

  private_class_method :shelve_trays
end
