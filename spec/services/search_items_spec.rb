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

  context "no filter" do
    let(:filter) { {} }

    it "returns an empty result" do
      expect(subject).to be_kind_of(described_class::EmptyResults)
      expect(results).to eq []
    end
  end

  describe "criteria_type" do
    describe "any" do
      let(:filter) { { criteria_type: "any" } }

      [
        :barcode,
        :bib_number,
        :call_number,
        :isbn_issn,
        :title,
        :author,
      ].each do |field|
        it "searches #{field}" do
          allow(item).to receive(field).and_return("#{field} value")
          Sunspot.index(item)
          Sunspot.commit
          filter[:criteria] = item.send(field)
          expect(results.first).to eq(item)
        end
      end

      it "searches the tray barcode" do
        item.tray = FactoryGirl.create(:tray)
        Sunspot.index(item)
        Sunspot.commit
        filter[:criteria] = item.tray.barcode
        expect(results.first).to eq(item)
      end

      it "searches the shelf barcode" do
        item.shelf = FactoryGirl.create(:shelf)
        Sunspot.index(item)
        Sunspot.commit
        filter[:criteria] = item.shelf.barcode
        expect(results.first).to eq(item)
      end
    end
  end

end
