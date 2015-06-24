class SyncItemMetadata
  attr_reader :item, :user_id

  def self.call(item: item, user_id: user_id)
    new(item: item, user_id: user_id).sync
  end

  def initialize(item: item, user_id: user_id)
    @item = item
    @user_id = user_id
  end

  def sync
    response = ApiGetItemMetadata.call(barcode)
    if response.success?
      save_metadata(response.body)
      item
      true
    else
      handle_error(response)
      false
    end
  end

  private

    def user
      @user ||= User.find(user_id)
    end

    def handle_error(response)
      AddIssue.call(user_id, barcode, error_message(response))
      DestroyItem.call(item, user)
    end

    def error_message(response)
      if response.not_found?
        "Item not found."
      elsif response.unauthorized?
        "Unauthorized - Check API Key."
      elsif response.timeout?
        "API Timeout."
      else
        "Error #{response.status_code}"
      end
    end

    def save_metadata(data)
      item.update!(data)
      LogActivity.call(item, "UpdatedByAPI", nil, Time.now, user)
    end

    def barcode
      item.barcode
    end
end
