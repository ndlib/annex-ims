class ApiGetItemMetadata
  attr_reader :item, :background

  def self.call(item:, background: false)
    new(item: item, background: background).get_data!
  end

  def initialize(item:, background: false)
    @item = item
    @background = background
  end

  def background?
    background
  end

  def get_data!
    response = ApiHandler.get(action: :record, params: params, connection_opts: connection_opts)
    ActivityLogger.api_get_item_metadata(item: item, params: params, api_response: response)
    response
  end

  private

  def barcode
    item.barcode
  end

  def params
    {
      barcode: barcode,
    }
  end

  def connection_opts
    if background?
      {}
    else
      {
        timeout: Rails.configuration.settings.api_foreground_timeout,
        max_retries: Rails.configuration.settings.api_foreground_max_retries,
      }
    end
  end
end
