class SyncItemMetadata
  attr_reader :item, :user_id, :background

  def self.call(item:, user_id:, background: false)
    new(item: item, user_id: user_id, background: background).sync
  end

  def initialize(item:, user_id:, background: false)
    @item = item
    @user_id = user_id
    @background = background
  end

  def sync
    if sync_required?
      perform_sync
    else
      true
    end
  end

  def background?
    background
  end

  private

  def perform_sync
    response = ApiGetItemMetadata.call(barcode: barcode, background: background)
    if response.success?
      save_metadata(response.body)
      true
    else
      handle_error(response)
      false
    end
  end

  def sync_required?
    sync_required_based_on_status? && sync_allowed_based_on_time?
  end

  def sync_required_based_on_status?
    item.metadata_status != "complete"
  end

  def sync_allowed_based_on_time?
    if background?
      true
    else
      item.metadata_updated_at.blank? || 10.minutes.ago > item.metadata_updated_at
    end
  end

  def user
    @user ||= User.find(user_id)
  end

  def handle_error(response)
    AddIssue.call(user_id, barcode, error_message(response))
    if response.not_found?
      handle_not_found
    else
      handle_other_error
    end
  end

  def handle_not_found
    save_metadata_status("not_found")
    LogActivity.call(item, "MetadataNotFound", nil, Time.now, user)
  end

  def handle_other_error
    save_metadata_status("error")
    LogActivity.call(item, "MetadataError", nil, Time.now, user)
  end

  def error_message(response)
    if response.not_found?
      "Item not found."
    elsif response.unauthorized?
      "Unauthorized - Check API Key."
    elsif response.timeout?
      "API Timeout."
    else
      "#{response.status_code}"
    end
  end

  def map_item_attributes(data)
    {
      title: data[:title],
      author: data[:author],
      chron: data[:description],
      bib_number: data[:bib_id],
      isbn_issn: data[:isbn_issn],
      conditions: data[:condition],
      call_number: data[:call_number],
    }
  end

  def save_metadata_status(status)
    item.update!(metadata_status_attributes(status))
  end

  def metadata_status_attributes(status)
    {
      metadata_status: status,
      metadata_updated_at: Time.now,
    }
  end

  def save_metadata(data)
    update_attributes = map_item_attributes(data).
      merge(metadata_status_attributes("complete"))
    item.update!(update_attributes)
    LogActivity.call(item, "UpdatedByAPI", nil, Time.now, user)
  end

  def barcode
    item.barcode
  end
end
