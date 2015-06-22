class GetItemFromBarcode
  attr_reader :user_id, :barcode

  def self.call(user_id, barcode)
    new(user_id, barcode).get
  end

  def initialize(user_id, barcode)
    @user_id = user_id
    @barcode = barcode
  end

  def get
    if valid?
      GetItemDataJob.perform_later(user_id, barcode)

      item = Item.where(barcode: barcode).first

      item
    else
      raise "barcode is not an item"
    end
  end

  private

    def valid?
      IsItemBarcode.call(barcode)
    end
end
