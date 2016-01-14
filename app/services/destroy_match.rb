class DestroyMatch
  def self.call(match:, user:)
    new(match, user).destroy!
  end

  def initialize(match, user)
    @match = match
    @user = user
  end

  def destroy!
    status = @match.destroy!
    ActivityLogger.remove_match(item: @match.item, request: @match.request, user: @user)
    status
  end
end
