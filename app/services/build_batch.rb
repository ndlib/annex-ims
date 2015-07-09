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
    if user.batches.where(active: true).count == 0
      batch = Batch.new
      batch.user = user
      batch.active = true
      batch.save!
    else
      batch = user.batches.where(active: true).first
    end

    batch_data.each do |data|

      lexed_data = data.split('-')

      request = Request.find(lexed_data[0])
      item = Item.find(lexed_data[1])

      match = Match.new
      match.item = item
      match.batch = batch
      match.request = request
      match.save!
    end

    batch.requests.each do |r|
      ActivityLogger.batch_request(request: r, user: user)
    end

    return batch

  end


end
