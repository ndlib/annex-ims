class BuildBatch
  attr_reader :batch_data

  def self.call(batch_data)
    new(batch_data).build!
  end

  def initialize(batch_data)
    @batch_data = batch_data
  end

  def build!
    batch = Batch.new

    batch_data.each do |data|
      lexed_data = data.split('-')

      request = Request.find(lexed_data[0])
      batch.requests << request

      item = Item.find(lexed_data[1])
      batch.items << item
    end

    batch.save!
    return batch

  end


end
