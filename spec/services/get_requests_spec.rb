require "rails_helper"

RSpec.describe GetRequests do
  subject { described_class.call }
  let!(:item) { FactoryGirl.create(:item, barcode: "987654321") }

  it "creates requests" do
    stub_api_active_requests
    expect(SyncItemMetadataJob).to receive(:perform_later).exactly(:once)
    expect { subject }.to change { Request.count }.by(4)
    expect(subject).to be_a_kind_of(Array)
    expect(subject.count).to eq(4)
    expect(subject.first.trans).to eq("illiad_85132100")
  end

  it "logs requests" do
    stub_api_active_requests
    expect(ActivityLogger).to receive(:receive_request).with(request: kind_of(Request)).exactly(4).times
    subject
  end

  describe "request data" do
    let(:requests_data) { { requests: [data] } }
    let(:data) do
      {
        transaction: "aleph-000367092",
        request_date_time: "2015-08-28T15:00:00Z",
        request_type: "Doc Del",
        delivery_type: "Loan",
        source: "Aleph",
        title: "Chemistry in Britain.",
        author: "author",
        description: "v.25 (1989)",
        pages: "pages",
        journal_title: "journal_title",
        article_title: "article_title",
        article_author: "article_author",
        barcode: "00000014443212",
        isbn_issn: "isbn_issn",
        bib_number: "000663270",
        adm_number: "000663270",
        ill_system_id: "ill_system_id",
        item_sequence: "00070",
        call_number: "TP 1 .C5174",
        send_to: "Hesburgh Library",
        rush: "No",
        patron_status: "Grad",
        patron_department: "Chemical Engineering",
        patron_institution: "University of Notre Dame",
        pickup_location: "Hesburgh Library"
      }
    end
    let(:request) { subject.first }

    before do
      stub_api_active_requests(body: requests_data.to_json)
    end

    it "does not error on non-utf8 characters" do
      stub_api_active_requests(body: api_fixture_data("active_requests_latin1.json"))
      expect { subject }.to_not raise_error
    end

    it "sets expected values" do
      [
        :title,
        :article_title,
        :author,
        :description,
        :barcode,
        :isbn_issn,
        :bib_number,
        :patron_status,
        :patron_department,
        :patron_institution,
        :pickup_location,
      ].each do |field|
        expect(request.send(field)).to eq(data.fetch(field))
      end
    end
  end
end
