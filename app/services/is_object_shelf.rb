module IsObjectShelf
  CLASS_NAME = "Shelf".freeze
  def self.call(shelf)
    (shelf.class.to_s == CLASS_NAME) ? true : false
  end
end
