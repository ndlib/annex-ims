class DeaccessionItem
  attr_reader :item, :user

  def self.call(item, user)
    new(item, user).deaccession!
  end

  def initialize(item, user)
    @item = item
    @user = user
  end

  def deaccession!
    validate_input!

    item.deaccessioned!
    UpdateIngestDate.call(item)
    SyncItemMetadata.call(item: item, user_id: nil, background: true)
    ApiDeaccessionItemJob.perform_later(item: item)

    if item.save!
      comment = item.try(:requests).order(created_at: :desc).first.try(:comment)
      ActivityLogger.deaccession_item(item: item, user: user, disposition: item.disposition, comment: { comment: comment })
      result = item
    else
      result = false
    end

    result
  end

  private

  def validate_input!
    if IsObjectItem.call(item)
      true
    else
      raise "object is not an item"
    end
  end
end
