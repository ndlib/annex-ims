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

  def process_in_background
    if !background?
      SyncItemMetadataJob.perform_later(item: item, user_id: user_id)
    end
  end

  def handle_error(error)
    save_metadata_status(error[:status])
    if(error[:issue])
      AddIssue.call(user_id, barcode, error[:issue])
    end
    if(error[:activity])
      LogActivity.call(item, error[:activity], nil, Time.now, user)
    end
    if(error[:enqueue])
      process_in_background
    end
  end

  # If there is any error in the response status, or with the data in the response,
  # get_error will return a json { type:, status:, issue:, activity:, enqueue: }
  # otherwise if there are no errors in the response, will return nil
  def get_error(response)
    if response.success?
      get_data_error(response)
    elsif response.not_found?
      { type: :not_found, status: :not_found, issue: "Item not found.", activity: "MetadataNotFound" }
    elsif response.unauthorized?
      { type: :unauthorized, status: :error, issue: "Unauthorized - Check API Key.", activity: "MetadataUnauthorized", enqueue: true }
    elsif response.timeout?
      { type: :timeout, status: :error, issue: "API Timeout.", activity: "MetadataTimeout", enqueue: true }
    else
      { type: :unknown, status: :error, issue: "#{response.status_code}", activity: "MetadataError#{response.status_code}", enqueue: true }
    end
  end

  # Check to see if there is any error in the data received from from the api
  # If there is an error, get_data_error will return a json { type:, status:, issue:, activity:, enqueue: }
  # otherwise if there are no errors with the data, will return nil
  def get_data_error(response)
    if !(response.body.has_key?(:sublibrary)) || response.body[:sublibrary] != "ANNEX"
      { type: :not_for_annex, status: :not_for_annex, issue: "Not marked for Annex", activity: "MetadataFoundNotMarkedForAnnex" }
    else
      nil
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
    LogActivity.call(item, "MetadataUpdated", nil, Time.now, user)
  end

  def barcode
    item.barcode
  end
end
