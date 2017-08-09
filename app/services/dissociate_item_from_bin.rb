class DissociateItemFromBin
  attr_reader :item, :user

  def self.call(item:, user:)
    new(item: item, user: user).dissociate!
  end

  def initialize(item:, user:)
    @item = item
    @user = user
  end

  def dissociate!
    # Only dissociate if there are no remaining matches for this item
    if no_remaining_matches?
      ActivityLogger.dissociate_item_and_bin(item: item, bin: item.bin, user: user)
      if IsDeacBinBarcode.call(item.bin.barcode)
        DeaccessionItem.call(item, user)
      end
      item.update!(bin: nil)
      true
    else
      false
    end
  end

  private

  def no_remaining_matches?
    item.bin && item.bin.matches.where(item: item).empty?
  end
end
