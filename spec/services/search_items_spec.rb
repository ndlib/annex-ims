require 'rails_helper'

RSpec.describe SearchItems, search: true do
  let(:item) { FactoryGirl.create(:item, chron: "TEST CHRON") }
  let(:deac_item) { FactoryGirl.create(:item, status: 9, title: item.title) }
  let(:filter) { { } }
  subject { described_class.call(filter) }

  def cleanFulltext(text)
    text.gsub(/[\-\.]/, "")
  end

  context "no filter" do
    let(:filter) { {} }

    it "returns an empty result" do
      expect(subject).to be_kind_of(described_class::EmptyResults)
      expect(subject.results).to eq []
      expect(subject.total).to eq(0)
    end
  end

  context "search" do
    before :each do
      save_all
    end

    after :all do
      Item.remove_all_from_index!
    end

    def save_all
      item.save!
      item.reload
      item.index!
      Sunspot.commit
      deac_item.save!
      deac_item.reload
      deac_item.index!
      Sunspot.commit
    end

    let(:filter) { { criteria_type: "any", criteria: deac_item.title } }

    it "does not return deaccessioned items", search: true do
      subject
      expect(Sunspot.session).to have_search_params(:without, :status, "deaccessioned")
    end
  end

  context "page" do
    let(:filter) { { criteria_type: "any", criteria: item.title, page: 2 } }

    it "returns the second page of results" do
      expect(subject.results).to eq([])
      expect(Sunspot.session).to be_a_search_for(Item)
      expect(Sunspot.session).to have_search_params(:paginate, page: 2, per_page: 50)
    end
  end

  context "per_page" do
    let(:item) { FactoryGirl.create(:item, chron: "1") }
    let(:filter) { { criteria_type: "any", criteria: item.title } }

    it "defaults to 50 per page" do
      subject
      expect(Sunspot.session).to have_search_params(:paginate, page: 1, per_page: 50)
    end

    context "1 per page" do
      it "limits to 1 per page" do
        filter[:per_page] = 1
        subject
        expect(Sunspot.session).to have_search_params(:paginate, page: 1, per_page: 1)
      end
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
          value = "#{field} value"
          allow(item).to receive(field).and_return(value)
          filter[:criteria] = item.send(field)
          subject
          expect(Sunspot.session).to have_search_params(:fulltext) {
            fulltext(cleanFulltext(value)) do
              minimum_match "75%"
            end
          }
        end
      end

      it "searches the tray barcode" do
        item.tray = FactoryGirl.create(:tray)
        filter[:criteria] = item.tray.barcode
        subject
        expect(Sunspot.session).to have_search_params(:fulltext) {
          fulltext(cleanFulltext(item.tray.barcode)) do
            minimum_match "75%"
          end
        }
      end

      it "searches the shelf barcode" do
        item.shelf = FactoryGirl.create(:shelf)
        filter[:criteria] = item.shelf.barcode
        subject
        expect(Sunspot.session).to have_search_params(:fulltext) {
          fulltext(cleanFulltext(item.shelf.barcode)) do
            minimum_match "75%"
          end
        }
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

        it "can search by #{criteria_type_field}" do
          value = "#{criteria_type_field} value"
          allow(item).to receive(criteria_type_field).and_return(value)
          filter[:criteria] = item.send(criteria_type_field)
          subject
          expect(Sunspot.session).to have_search_params(:fulltext) {
            fulltext(cleanFulltext(value),
                     fields:  [criteria_type_field]) do
              minimum_match "75%"
            end
          }
        end
      end
    end

    describe "tray" do
      let(:filter) { { criteria_type: "tray" } }

      it "searches the tray barcode" do
        item.tray = FactoryGirl.create(:tray)
        filter[:criteria] = item.tray.barcode
        subject
        expect(Sunspot.session).to have_search_params(:with, :tray_barcode, item.tray.barcode)
      end
    end

    describe "shelf" do
      let(:filter) { { criteria_type: "shelf" } }

      it "searches the shelf barcode" do
        item.shelf = FactoryGirl.create(:shelf)
        filter[:criteria] = item.shelf.barcode
        subject
        expect(Sunspot.session).to have_search_params(:with, :shelf_barcode, item.shelf.barcode)
      end
    end
  end

  context "conditions" do
    let(:conditions) { ["COVER-MISS", "PAGES-BRITTLE", "SPINE-DET"] }
    let(:item) { FactoryGirl.create(:item, conditions: conditions) }

    context "all" do
      let(:filter) { { condition_bool: "all" } }

      it "uses all given conditions" do
        filter[:conditions] = {}.tap do |hash|
          conditions.each { |c| hash[c] = true }
        end
        subject
        for condition in conditions do
          expect(Sunspot.session).to have_search_params(:with, :conditions, condition)
        end
      end
    end

    context "any" do
      let(:filter) { { condition_bool: "any" } }

      it "uses any given conditions" do
        filter[:conditions] = {}.tap do |hash|
          conditions.each { |c| hash[c] = true }
        end
        subject
        expect(Sunspot.session).to have_search_params(:with, :conditions, conditions)
      end
    end

    context "any" do
      let(:filter) { { condition_bool: "none" } }

      it "uses without given conditions" do
        filter[:conditions] = {}.tap do |hash|
          conditions.each { |c| hash[c] = true }
        end
        subject
        for condition in conditions do
          expect(Sunspot.session).to have_search_params(:without, :conditions, condition)
        end
      end
    end
  end

  context "date_type" do
    let(:filter_date) { 1.week.ago }
    let(:start) { filter_date.ago(1.week).to_s }
    let(:finish) { filter_date.since(1.week).to_s }

    {
      request: :requested,
      initial: :initial_ingest,
      last: :last_ingest,
    }.each do |date_type, search_field|
      context "#{date_type}" do
        let(:filter) { { date_type: date_type.to_s, start: start, finish: finish } }

        it "searches the #{date_type} date" do
          subject
          expect(Sunspot.session).to have_search_params(:with, search_field.to_s, start..finish)
        end

        context "no end date" do
          let(:filter) { { date_type: date_type.to_s, start: start } }
          it "searches greater or equal" do
            subject
            expect(Sunspot.session).to_not have_search_params(:with, search_field.to_s, start..finish)
          end
        end

        context "no start date" do
          let(:filter) { { date_type: date_type.to_s, finish: finish } }
          it "searches less or equal" do
            subject
            expect(Sunspot.session).to_not have_search_params(:with, search_field.to_s, start..finish)
          end
        end
      end
    end

  end
end
