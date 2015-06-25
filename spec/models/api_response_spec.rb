require "rails_helper"

RSpec.describe ApiResponse do
  let(:status_code) { 200 }
  let(:data) do
    {
      title: "title",
      author: "author",
      chron: "chron",
      bib_number: "bib_number",
      isbn_issn: "isbn",
      conditions: "conditions",
      call_number: "call_number",
    }
  end

  subject { described_class.new(status_code: status_code, body: data) }

  context "success" do
    let(:status_code) { 200 }

    it "returns true for success?" do
      expect(subject.success?).to eq(true)
    end

    it "returns false for error?" do
      expect(subject.error?).to eq(false)
    end
  end

  shared_examples "an error response" do
    it "returns false for success?" do
      expect(subject.success?).to eq(false)
    end

    it "returns true for error?" do
      expect(subject.error?).to eq(true)
    end
  end

  context "internal error" do
    let(:status_code) { 500 }

    it_behaves_like "an error response"
  end

  context "timeout" do
    let(:status_code) { 599 }

    it_behaves_like "an error response"

    it "returns true for timeout?" do
      expect(subject.timeout?).to eq(true)
    end
  end

  context "unauthorized" do
    let(:status_code) { 401 }

    it_behaves_like "an error response"

    it "returns true for unauthorized?" do
      expect(subject.unauthorized?).to eq(true)
    end
  end

  context "not_found" do
    let(:status_code) { 404 }

    it_behaves_like "an error response"

    it "returns true for not_found?" do
      expect(subject.not_found?).to eq(true)
    end
  end

  context "body" do
    it "can be accessed with string or symbol keys" do
      expect(subject.body[:title]).to eq("title")
      expect(subject.body["title"]).to eq("title")
    end
  end

  context "array body" do
    let(:data) { [1, 2, 3] }

    it "has the array as the body" do
      expect(subject.body).to eq([1, 2, 3])
    end
  end

  context "body with string keys" do
    let(:data) do
      {
        "title" => "string title",
        "author" => "string authors",
      }
    end

    it "can be accessed with symbols" do
      expect(subject.body[:title]).to eq("string title")
    end
  end
end
