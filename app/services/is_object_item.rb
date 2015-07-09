module IsObjectItem
  def self.call(item)
    (item.class.to_s == "Item") ? true : false
  end
end
