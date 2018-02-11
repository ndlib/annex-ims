require "rails_helper"

RSpec.describe MergeNewMetadataToOldItem do
  subject { described_class.call(old_id: old_id, new_id: new_id, user_id: user_id) }

  let(:user) { FactoryGirl.create(:user) }
  let(:user_id) { user.id }
  let(:old_item) { FactoryGirl.create(:item) }
  let(:old_id) { old_item.id }
  let(:new_item) { FactoryGirl.create(:item) }
  let(:new_id) { new_item.id }

  context "merging items" do
    it "merges new metadata into an old matching item" do
      old_item
      new_item
      barcode = new_item.barcode
      subject
      item = Item.find(old_item.id)
      expect(item.barcode).to eq(barcode)
      expect(item.bib_number).to eq(new_item.bib_number)
      expect(item.title).to eq(new_item.title)
      expect(item.author).to eq(new_item.author)
      expect(item.chron).to eq(new_item.chron)
      expect(item.isbn_issn).to eq(new_item.isbn_issn)
    end

    it "logs the merge" do
      # "add log test"
    end
  end
end
