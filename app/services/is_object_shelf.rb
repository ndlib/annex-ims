class IsObjectShelf
  attr_reader :shelf

  def self.call(shelf)
    new(shelf).compare
  end

  def initialize(shelf)
    @shelf = shelf
  end

  def compare
    (@shelf.class.to_s == "Shelf") ? true : false
  end

end
