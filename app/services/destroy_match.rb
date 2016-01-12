class DestroyMatch
  attr_reader :match, :user

  def self.call(match:, user:)
    new(match, user).destroy!
  end

  def initialize(match, user)
    @match = match
    @user = user
  end

  def destroy!
    ActiveRecord::Base.transaction do
      status = match.destroy!
      ActivityLogger.remove_match(item: match.item, request: match.request, user: user)
      dissociate_bin
      return status
    end
    false
  end

private

  def item
    match.item
  end

  def dissociate_bin
    # If there are no remaining matches for this item and bin, dissociate the item/bin
    if match.bin && match.bin.matches.where(item: item).empty?
      ActivityLogger.dissociate_item_and_bin(item: item, bin: item.bin, user: user)
      item.update!(bin: nil)
    end
  end
end
