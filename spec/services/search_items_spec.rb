require 'rails_helper'

RSpec.describe SearchItems do
  before(:each) do
    ::Sunspot.session = ::Sunspot::Rails::StubSessionProxy.new(::Sunspot.session)
  end

  after(:each) do
    ::Sunspot.session = ::Sunspot.session.original_session
  end

  let(:item) { FactoryGirl.create(:item, chron: "TEST CHRON") }
  let(:filter) { {} }
  subject { described_class.new(filter) }
  let(:results) { [item] }

  before do
    Item.remove_all_from_index!
    Sunspot.index(item)
    Sunspot.commit
  end

  describe "#page" do
    context "when page param is present" do
      let(:filter) { { criteria_type: "any", criteria: item.title, page: 2 } }

      it "returns the the page param" do
        expect(subject.page).to eq(2)
      end
    end

    context "when page param is absent" do
      it "returns 1" do
        expect(subject.page).to eq(1)
      end
    end
  end

  describe "#per_page()" do
    context "when per_page is set" do
      it "returns the per_page param" do
        filter[:per_page] = 1
        expect(subject.per_page).to eq(1)
      end
    end

    context "when per_page is not set" do
      it "returns 50" do
        expect(subject.per_page).to eq(50)
      end
    end
  end

  describe "#conditions" do
    context "when condition list is present" do
      let(:conditions) { { "COVER-MISS" => true, "PAGES-BRITTLE" => true, "SPINE-DET" => true } }
      let(:filter) { { criteria_type: "any", criteria: item.title, conditions: conditions } }

      it "returns the condition list" do
        expect(subject.conditions).to eq(["COVER-MISS", "PAGES-BRITTLE", "SPINE-DET"])
      end
    end

    context "when condition list is empty" do
      it "returns nil" do
        expect(subject.conditions).to be_nil
      end
    end
  end

  describe "#search!" do
    context "when fulltext, conditions or date is present" do
      let(:filter) { { criteria_type: "any", criteria: item.title } }

      it "returns the result set" do
        allow_any_instance_of(described_class).to receive(:search_results).and_return(results)
        expect(subject.search!).to eq(results)
      end
    end

    context "when conditions are not present" do
      it "returns the empty result set" do
        allow_any_instance_of(described_class).to receive(:search_results).and_return(results)
        expect(subject.search!).to be_kind_of(described_class::EmptyResults)
      end
    end
  end
end
