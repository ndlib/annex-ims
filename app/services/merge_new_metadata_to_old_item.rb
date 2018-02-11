class MergeNewMetadataToOldItem
  attr_reader :old_id, :new_id, :user_id

  def self.call(old_id:, new_id:, user_id:)
    new(old_id: old_id, new_id: new_id, user_id: user_id).merge
  end

  def initialize(old_id:, new_id:, user_id:)
    @old_id = old_id
    @new_id = new_id
    @user_id = user_id
  end

  def merge
    old_item = Item.find(@old_id)
    new_item = Item.find(@new_id)
    user = User.find(@user_id)

    barcode = new_item.barcode

    new_item.barcode = Digest::SHA256.hexdigest(barcode)
    new_item.save!

    old_item.barcode = barcode
    old_item.bib_number = new_item.bib_number
    old_item.title = new_item.title
    old_item.author = new_item.author
    old_item.chron = new_item.chron
    old_item.isbn_issn = new_item.isbn_issn

    old_item.save!

    ActivityLogger.update_barcode(item: old_item, user: user)
  end
end
