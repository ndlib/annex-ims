module IsObjectShelf
  def self.call(shelf)
    (shelf.class.to_s == "Shelf") ? true : false
  end
end
