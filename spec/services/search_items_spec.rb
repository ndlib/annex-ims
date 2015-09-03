require 'rails_helper'

RSpec.describe SearchItems do
  include SolrSpecHelper

  before :all do
    solr_setup
  end

  after :all do
    Item.remove_all_from_index!
  end

  let(:item) { FactoryGirl.create(:item, chron: "TEST CHRON") }
  let(:filter) { {} }
  subject { described_class.call(filter) }
  let(:results) { subject.results }

  before do
    Item.remove_all_from_index!
    Sunspot.index(item)
    Sunspot.commit
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

      it "does not match a nonexistant value" do
        filter[:criteria] = "fake value"
        expect(results).to eq([])
      end
    end

    [
      :barcode,
      :bib_number,
      :call_number,
      :isbn_issn,
      :title,
      :author,
    ].each do |criteria_type_field|
      describe "#{criteria_type_field}" do
        let(:filter) { { criteria_type: criteria_type_field.to_s } }
        it "can find an item by #{criteria_type_field}" do
          allow(item).to receive(criteria_type_field).and_return("#{criteria_type_field} value")
          Sunspot.index(item)
          Sunspot.commit
          filter[:criteria] = item.send(criteria_type_field)
          expect(results.first).to eq(item)
        end

        it "cannot find an item by #{criteria_type_field}" do
          filter[:criteria] = "fake value"
          expect(results).to eq([])
        end
      end
    end

    describe "tray" do
      let(:filter) { { criteria_type: "tray" } }

      it "searches the tray barcode" do
        item.tray = FactoryGirl.create(:tray)
        Sunspot.index(item)
        Sunspot.commit
        filter[:criteria] = item.tray.barcode
        expect(results.first).to eq(item)
      end

      it "does not match a nonexistant value" do
        filter[:criteria] = "fake value"
        expect(results).to eq([])
      end
    end

    describe "shelf" do
      let(:filter) { { criteria_type: "shelf" } }

      it "searches the shelf barcode" do
        item.shelf = FactoryGirl.create(:shelf)
        Sunspot.index(item)
        Sunspot.commit
        filter[:criteria] = item.shelf.barcode
        expect(results.first).to eq(item)
      end

      it "does not match a nonexistant value" do
        filter[:criteria] = "fake value"
        expect(results).to eq([])
      end
    end

    describe "ERROR" do
      let(:filter) { { criteria_type: "ERROR", criteria: "ERROR" } }

      it "returns an empty result set" do
        filter[:criteria] = "ERROR"
        expect(results).to eq([])
      end
    end
  end
end
