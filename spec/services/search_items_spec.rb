require 'rails_helper'

RSpec.describe SearchItems do
  include SolrSpecHelper

  before :all do
    solr_setup
    Item.remove_all_from_index!
  end

  after :all do
    Item.remove_all_from_index!
  end

  it "can find an item by barcode" do
    item = FactoryGirl.create(:item, chron: 'TEST CHRON')
    Sunspot.index(item)
    Sunspot.commit
    search = SearchItems.call(criteria_type: "barcode", criteria: item.barcode)
    expect(item).to eq search.results.first
  end

end
