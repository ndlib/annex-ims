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
      expect(subject.results).to eq []
      expect(subject.total).to eq(0)
    end
  end

  context "page" do
    let(:filter) { { criteria_type: "any", criteria: item.title, page: 2 } }

    it "returns the second page of results" do
      expect(subject.total).to eq(1)
      expect(subject.results).to eq([])
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

  context "conditions" do
    let(:conditions) { ["COVER-MISS", "PAGES-BRITTLE", "SPINE-DET"] }
    let(:other_conditions) { ["COVER-TORN", "NEEDS-ENCLS"] }
    let(:item) { FactoryGirl.create(:item, conditions: conditions) }

    context "all" do
      let(:filter) { { condition_bool: "all" } }

      it "matches all conditions" do
        filter[:conditions] = {}.tap do |hash|
          conditions.each { |c| hash[c] = true }
        end
        expect(results.first).to eq(item)
      end

      it "matches partial conditions" do
        filter[:conditions] = {}.tap do |hash|
          conditions[0,2].each { |c| hash[c] = true }
        end
        expect(results.first).to eq(item)
      end

      it "does not match an extra condition" do
        filter[:conditions] = {}.tap do |hash|
          (conditions + other_conditions).each { |c| hash[c] = true }
        end
        expect(results).to eq([])
      end
    end

    context "any" do
      let(:filter) { { condition_bool: "any" } }

      it "matches all conditions" do
        filter[:conditions] = {}.tap do |hash|
          conditions.each { |c| hash[c] = true }
        end
        expect(results.first).to eq(item)
      end

      it "matches partial conditions" do
        filter[:conditions] = {}.tap do |hash|
          conditions[0,2].each { |c| hash[c] = true }
        end
        expect(results.first).to eq(item)
      end

      it "matches as long as one condition matches" do
        filter[:conditions] = {}.tap do |hash|
          (conditions[0,1] + other_conditions).each { |c| hash[c] = true }
        end
        expect(results.first).to eq(item)
      end

      it "does not match if no conditions match" do
        filter[:conditions] = {}.tap do |hash|
          other_conditions.each { |c| hash[c] = true }
        end
        expect(results).to eq([])
      end
    end

    context "any" do
      let(:filter) { { condition_bool: "none" } }

      it "does not match all conditions" do
        filter[:conditions] = {}.tap do |hash|
          conditions.each { |c| hash[c] = true }
        end
        expect(results).to eq([])
      end

      it "does not match partial conditions" do
        filter[:conditions] = {}.tap do |hash|
          conditions[0,2].each { |c| hash[c] = true }
        end
        expect(results).to eq([])
      end

      it "does not match if one condition matches" do
        filter[:conditions] = {}.tap do |hash|
          (conditions[0,1] + other_conditions).each { |c| hash[c] = true }
        end
        expect(results).to eq([])
      end

      it "matches if no conditions match" do
        filter[:conditions] = {}.tap do |hash|
          other_conditions.each { |c| hash[c] = true }
        end
        expect(results.first).to eq(item)
      end
    end
  end

  context "date_type" do
    let(:filter_date) { 1.week.ago }

    context "request" do
      let(:request) { FactoryGirl.create(:request, requested: filter_date) }
      let(:item) do
        FactoryGirl.create(:item).tap do |i|
          allow(i).to receive(:requests).and_return([request])
        end
      end
      let(:filter) { { date_type: "request", start: filter_date.ago(1.week).to_s, finish: filter_date.since(1.week).to_s } }

      it "matches the request date" do
        expect(results.first).to eq(item)
      end

      it "does not match if the start date is after the request date" do
        filter[:start] = filter_date.since(1.day).to_s
        expect(results).to eq([])
      end

      it "does not match if the finish date is before the request date" do
        filter[:finish] = filter_date.ago(1.day).to_s
        expect(results).to eq([])
      end
    end

    {
      initial: :initial_ingest,
      last: :last_ingest,
    }.each do |date_type, date_field|
      context date_type.to_s do
        let(:item) { FactoryGirl.create(:item, date_field => filter_date) }
        let(:filter) { { date_type: date_type.to_s, start: filter_date.ago(1.week).to_s, finish: filter_date.since(1.week).to_s } }

        it "matches the date" do
          expect(results.first).to eq(item)
        end

        it "does not match if the start date is after the request date" do
          filter[:start] = filter_date.since(1.day).to_s
          expect(results).to eq([])
        end

        it "does not match if the finish date is before the request date" do
          filter[:finish] = filter_date.ago(1.day).to_s
          expect(results).to eq([])
        end
      end
    end
  end
end
