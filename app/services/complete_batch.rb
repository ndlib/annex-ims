class CompleteBatch
  def self.call(batch:, user:)
    new(batch, user).complete_batch!
  end

  def initialize(batch, user)
    @batch = batch
    @user = user
  end

  def complete_batch!
    FinishBatch.call(@batch, @user) unless remaining_matches?
  end

  def remaining_matches?
    true if @batch.matches.count >= 1
  end
end
