class FinishBatch
  attr_reader :batch

  def self.call(batch)
    new(batch).finish!
  end

  def initialize(batch)
    @batch = batch
  end

  def finish!
    @batch.skipped_matches.each do |s|
      s.destroy! # accepted matches will remain, so those requests will stay out of queue. Skipped requests will go back in the queue.
    end

    @batch.active = false
    @batch.save!
  end
end
