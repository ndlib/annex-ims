require "rails_helper"

RSpec.describe MergeNewMetadataToOldItem do
  include ItemMetadata

  subject { described_class.call(old_id: old_id, new_barcode: @new_barcode, user_id: user_id) }

  let(:user) { FactoryBot.create(:user) }
  let(:user_id) { user.id }
  let(:old_item) { FactoryBot.create(:item) }
  let(:old_id) { old_item.id }
  let(:barcode) { '00000007819006' }

  context "merging items" do
    before(:each) do
      data = api_fixture_data('item_metadata.json')
      hash = JSON.parse(data)
      new_hash = map_item_attributes(hash.symbolize_keys)
      new_hash['barcode'] = barcode
      @new_item = Item.new(new_hash)
      @new_barcode = @new_item.barcode
      stub_api_item_metadata(barcode: @new_barcode)
    end

    it "merges new metadata into an old matching item" do
      old_item
      barcode = @new_item.barcode
      subject
      item = Item.find(old_item.id)
      expect(item.barcode).to eq(barcode)
      expect(item.bib_number).to eq(@new_item.bib_number)
      expect(item.title).to eq(@new_item.title)
      expect(item.author).to eq(@new_item.author)
      expect(item.chron).to eq(@new_item.chron)
      expect(item.isbn_issn).to eq(@new_item.isbn_issn)
    end

    it "logs the merge" do
      expect(ActivityLogger).to receive(:update_barcode).with(item: kind_of(Item), user: user)
      subject
    end
  end
end
