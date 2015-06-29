class ApiGetItemMetadata
  attr_reader :barcode, :background

  def self.call(barcode:, background: false)
    new(barcode: barcode, background: background).get_data!
  end

  def initialize(barcode:, background: false)
    @barcode = barcode
    @background = background
  end

  def background?
    background
  end

  def get_data!
    ApiHandler.get(action: :record, params: { barcode: barcode }, connection_opts: connection_opts)
  end

  private

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
