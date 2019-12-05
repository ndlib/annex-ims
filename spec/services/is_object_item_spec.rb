require "rails_helper"

RSpec.describe IsObjectItem do
  it "recognizes an item as an item" do
    item = Item.new
    expect(IsObjectItem.call(item)).to eq(true)
  end

  it "indicates shelf is not an item" do
    shelf = Shelf.new
    expect(IsObjectItem.call(shelf)).to eq(false)
  end
end
