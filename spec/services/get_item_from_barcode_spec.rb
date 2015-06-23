require 'rails_helper'

RSpec.describe GetItemFromBarcode do
  subject { described_class.call(user.id, barcode) }

  let(:api_response_status) { 200 }
  let(:item) { instance_double(Item, attributes: item_attr) }
  let(:user) { instance_double(User, username: "bob", id: 1) }
  let(:barcode) { 123456789 }
  let!(:data) { { "status" => api_response_status, "results" => item_attr } }
  let(:item_attr) {
    {
      "title"=>"Symphony no. 2, op. 16 : The four temperaments / Carl Nielsen.",
      "author"=>"Nielsen, Carl, 1865-1931.",
      "chron"=>"",
      "bib_number"=>"001883956",
      "isbn_issn"=>"0486418979",
      "conditions"=>nil,
      "call_number"=>"M 1001 .N5 S2 2002"
    }
  }

  before(:each) do
    allow(User).to receive(:find).and_return(user)
    allow(ApiGetItemMetadata).to receive(:call).with(barcode).and_return(data)
  end

  context "invalid barcode" do
    it "raises an error" do
      allow(IsItemBarcode).to receive(:call).and_return(false)
      expect{ subject }.to raise_error
    end
  end

  context "given a valid item" do
    it "updates the item with data from the api" do
      expect(subject.attributes).to include(item.attributes)
    end

    it "logs the activity" do
      expect(LogActivity).to receive(:call).with(anything, "Created", anything, anything, anything).ordered
      expect(LogActivity).to receive(:call).with(anything, "UpdatedByAPI", anything, anything, anything).ordered
      subject
    end
  end

  context "given an invalid item" do
    let(:api_response_status) { 404 }

    it "logs an issue" do
      expect(AddIssue).to receive(:call).with(user.id, barcode, "Item not found.")
      subject
    end

    it "destroys the item" do
      expect_any_instance_of(Item).to receive(:destroy!)
      subject
    end

    it "logs the activity" do
      expect(LogActivity).to receive(:call).with(anything, "Created", anything, anything, anything).ordered
      expect(LogActivity).to receive(:call).with(anything, "Destroyed", anything, anything, anything).ordered
      subject
    end
  end

  context "unauthorized api request" do
    let(:api_response_status) { 401 }

    it "logs an issue" do
      expect(AddIssue).to receive(:call).with(user.id, barcode, "Unauthorized - Check API Key.")
      subject
    end

    it "destroys the item" do
      expect_any_instance_of(Item).to receive(:destroy!)
      subject
    end

    it "logs the activity" do
      expect(LogActivity).to receive(:call).with(anything, "Created", anything, anything, anything).ordered
      expect(LogActivity).to receive(:call).with(anything, "Destroyed", anything, anything, anything).ordered
      subject
    end
  end

  context "api time out" do
    let(:api_response_status) { 599 }

    it "logs an issue" do
      expect(AddIssue).to receive(:call).with(user.id, barcode, "API Timeout.")
      subject
    end

    it "destroys the item" do
      expect_any_instance_of(Item).to receive(:destroy!)
      subject
    end

    it "logs the activity" do
      expect(LogActivity).to receive(:call).with(anything, "Created", anything, anything, anything).ordered
      expect(LogActivity).to receive(:call).with(anything, "Destroyed", anything, anything, anything).ordered
      subject
    end
  end
end
