require "rails_helper"

RSpec.describe IsObjectTray do
  it "recognizes a tray as a tray" do
    tray = Tray.new
    expect(IsObjectTray.call(tray)).to eq(true)
  end

  it "indicates shelf is not a tray" do
    shelf = Shelf.new
    expect(IsObjectTray.call(shelf)).to eq(false)
  end
end
