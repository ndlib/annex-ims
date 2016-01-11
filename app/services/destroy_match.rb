class DestroyMatch
  def self.call(match, user)
    new(match, user).destroy
  end

  def initialize(match, user)
    @match = match
    @user = user
  end

  def destroy
    ActiveRecord::Base.transaction do
      @match.destroy!
      ActivityLogger.remove_match(item: @match.item, request: @match.request, user: @user)
      determine_batch_status
    end
  rescue StandardError => e
    e.message
  end

  def determine_batch_status
    if !remaining_matches(@match.batch)
      FinishBatch.call(@match.batch)
      "batch destroyed"
    else
      "continue batch"
    end
  end

  def remaining_matches(batch)
    true if batch.matches.count >= 1
  end
end
