class CancelBatch
  attr_reader :batch_id

  def self.call(batch_id)
    new(batch_id).cancel!
  end

  def initialize(batch_id)
    @batch_id = batch_id
  end

  def cancel!
    batch = Batch.find(@batch_id)
    batch.matches.each do |match|
      match.destroy!
    end

    batch.destroy!
  end
end
