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

  let(:unindexed_item) { FactoryGirl.create(:item, chron: "TEST CHRON") }
  let(:item) do
    Sunspot.index(unindexed_item)
    Sunspot.commit
    unindexed_item
  end
  let(:filter) { {} }
  subject { described_class.call(filter) }
  let(:results) { subject.results }

  context "barcode" do
    let(:filter) { { criteria_type: "barcode", criteria: item.barcode } }
    it "can find an item by barcode" do
      expect(subject).to be_kind_of(Sunspot::Search::StandardSearch)
      expect(results.first).to eq item
    end
  end

  it "returns an empty result" do
    expect(subject).to be_kind_of(described_class::EmptyResults)
    expect(results).to eq []
  end

end
