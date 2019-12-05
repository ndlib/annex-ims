require "rails_helper"

RSpec.describe IsValidThickness do
  it "recognizes '1' as a valid thickness" do
    thickness = "1"
    expect(IsValidThickness.call(thickness)).to eq(true)
  end

  it "indicates 'TRAY-1234' is an invalid thickness" do
    thickness = "TRAY-1234"
    expect(IsValidThickness.call(thickness)).to eq(false)
  end
end
