class BuildBatch
  attr_reader :batch_data, :user, :batch_type

  def self.call(batch_data, user, batch_type = 0)
    new(batch_data, user, batch_type).build!
  end

  def initialize(batch_data, user, batch_type)
    @batch_data = batch_data
    @user = user
    @batch_type = batch_type
  end

  def build!
    if user.batches.where(active: true, batch_type: @batch_type).count == 0
      batch = Batch.new
      batch.user = user
      batch.batch_type = @batch_type
      batch.active = true
      batch.save!
    else
      batch = user.batches.where(active: true, batch_type: @batch_type).first
    end

    if !batch_data.empty?
      new_request_ids = []
      batch_data.each do |data|
        lexed_data = data.split("-")

        request = Request.find(lexed_data[0])
        item = Item.find(lexed_data[1])

        match = Match.new
        match.item = item
        match.batch = batch
        match.request = request
        match.save!
        ActivityLogger.match_item(item: item, request: request, user: user)

        new_request_ids.append request
      end

      new_requests = RequestQuery.new(batch.requests).find_all_by_id(id_array: new_request_ids)
      new_requests.each do |r|
        ActivityLogger.batch_request(request: r, user: user)
      end
    end

    batch
  end
end
