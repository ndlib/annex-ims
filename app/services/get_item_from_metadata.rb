require 'item_metadata'

class GetItemFromMetadata
  include ItemMetadata

  class GetItemFromMetadataError < StandardError; end

  attr_reader :barcode, :user_id

  def self.call(barcode:, user_id:)
    new(barcode: barcode, user_id: user_id).get
  end

  def initialize(barcode:, user_id:)
    @barcode = barcode
    @user_id = user_id
  end

  def get
    item = Item.new(barcode: @barcode)
    response = ApiGetItemMetadata.call(item: item, background: false)
    error = get_error(response)
    if error.nil?
      item = Item.new(map_item_attributes(response.body))
    else
      handle_error(item, error)
      item = nil
    end
  end

  private

  def handle_error(item, error)
    item.assign_attributes(metadata_status_attributes(error[:status]))
    if error[:issue_type]
      AddIssue.call(item: item, user: user, type: error[:issue_type])
    end
  end

end
