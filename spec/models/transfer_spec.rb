require "rails_helper"

RSpec.describe Transfer, type: :model do
  [:shelf, :initiated_by, :transfer_type].each do |field|
    it "requires field #{field}" do
      expect(subject).to respond_to(field)
      expect(subject).to respond_to("#{field}=")
    end
  end
end
