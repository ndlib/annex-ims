module IsObjectItem
  CLASS_NAME = "Item".freeze
  def self.call(item)
    item.class.to_s == CLASS_NAME
  end
end
