class ProcessMatch
  attr_reader :match, :user

  def self.call(match:, user:)
    new(match: match, user: user).process
  end

  def initialize(match:, user:)
    @match = match
    @user = user
  end

  def process
    ActiveRecord::Base.transaction do
      dissociate_bin
      scan_send
      complete_match
    end
    notify_api
    true
  end

  private

  def request
    match.request
  end

  def item
    match.item
  end

  def delivery_type
    if request.del_type == "scan"
      "scan"
    else
      "send"
    end
  end

  def dissociate_bin
    match.update!(bin: nil)
  end

  def scan_send
    if delivery_type == "send"
      ShipItem.call(item: item, request: request, user: user)
    else
      ScanItem.call(item: item, request: request, user: user)
    end
  end

  def notify_api
    ApiScanSendJob.perform_later(match: match)
  end

  def complete_match
    match.processed = "completed"
    match.save!
    request_query = RequestQuery.new(match.request)
    if request_query.remaining_matches.count == 0
      CompleteRequest.call(request: match.request, user: user)
    end
  end
end
