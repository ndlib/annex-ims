class IsObjectItem
  attr_reader :item

  def self.call(item)
    new(item).compare
  end

  def initialize(item)
    @item = item
  end

  def compare
    (@item.class.to_s == "Item") ? true : false
  end

end
