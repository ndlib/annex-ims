class FinishBatch
  def self.call(batch, user)
    new(batch, user).finish!
  end

  def initialize(batch, user)
    @batch = batch
    @user = user
  end

  def finish!
    @batch.skipped_matches.each do |match|
      # Skipped requests will go back in the queue.
      DestroyMatch.call(match: match, user: @user)
    end

    @batch.active = false
    @batch.save!
  end
end
