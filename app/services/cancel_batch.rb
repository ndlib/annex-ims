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

    batch.requests.each do |request|
      request.filled_by_item = nil
      request.filled_in_batch = nil
      request.save!
    end

    batch.matches.each(&:destroy!)

    batch.destroy!
  end
end
