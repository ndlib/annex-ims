require "item_metadata"

class SyncItemMetadata
  include ItemMetadata

  class SyncItemMetadataError < StandardError; end

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
    response = ApiGetItemMetadata.call(item: item, background: background)
    error = get_error(response)
    if error.nil?
      save_metadata(response.body)
      true
    else
      handle_error(error)
      false
    end
  end

  def sync_required?
    sync_required_based_on_status? && sync_allowed_based_on_time?
  end

  def sync_required_based_on_status?
    item.metadata_status != "complete" || metadata_stale?
  end

  def metadata_stale?
    if item.metadata_updated_at.present?
      item.metadata_updated_at < 24.hours.ago
    else
      false
    end
  end

  def sync_allowed_based_on_time?
    if background?
      true
    else
      item.metadata_updated_at.blank? || 10.minutes.ago > item.metadata_updated_at
    end
  end

  def process_in_background(error)
    if background?
      raise SyncItemMetadataError, "Error syncing item metadata. item: #{item.inspect}, error: #{error.inspect}"
    else
      SyncItemMetadataJob.perform_later(item: item, user_id: user_id)
    end
  end

  def handle_error(error)
    save_metadata_status(error[:status])
    if error[:issue_type]
      AddIssue.call(item: item, user: user, type: error[:issue_type])
    end
    if error[:enqueue]
      process_in_background(error)
    end
  end

  def save_metadata_status(status)
    item.update!(metadata_status_attributes(status))
  end

  def save_metadata(data)
    update_attributes = map_item_attributes(data).
                        merge(metadata_status_attributes("complete"))
    item.update!(update_attributes)
    ActivityLogger.update_item_metadata(item: item)
  end

  def barcode
    item.barcode
  end
end
