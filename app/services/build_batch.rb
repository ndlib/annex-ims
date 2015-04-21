class BuildBatch
  attr_reader :batch_data, :user

  def self.call(batch_data, user)
    new(batch_data, user).build!
  end

  def initialize(batch_data, user)
    @batch_data = batch_data
    @user = user
  end

  def build!
    batch = Batch.new
    batch.user = user

    batch_data.each do |data|
Rails.logger.info data.inspect
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
