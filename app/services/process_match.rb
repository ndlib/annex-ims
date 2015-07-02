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
    end
    notify_api
    true
  end

  private

  def delivery_type
    if match.request.del_type == "scan"
      "scan"
    else
      "send"
    end
  end

  def dissociate_bin
    LogActivity.call(match.item, "Dissociated", match.item.bin, Time.now, user)

    match.item.update!(bin: nil)
    match.update!(bin: nil)
  end

  def scan_send
    if delivery_type == "send"
      ShipItem.call(match.item, user)
    else
      ScanItem.call(match.item, user)
    end
  end

  def notify_api
    ApiScanSendJob.perform_later(match: match)
  end
end
