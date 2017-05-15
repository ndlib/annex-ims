require 'rails_helper'

RSpec.describe BuildDeaccessioningRequest do
  subject { described_class.call(item.id, disposition.id, comment) }
  let!(:disposition) { FactoryGirl.create(:disposition) }
  let!(:comment) { "Test comment" }
  let!(:item) { FactoryGirl.create(:item, barcode: '987654321') }

  it 'creates requests' do
    expect { subject }.to change { Request.count }.by(1)
    expect(subject).to be_a_kind_of(Array)
    expect(subject.count).to eq(1)
    expect(subject.first.trans).to start_with('DEACC_')
  end

  it 'logs requests' do
    expect(ActivityLogger).to receive(:receive_request).with(request: kind_of(Request)).exactly(1).times
    subject
  end

  describe 'request data' do
    let(:request) { subject.first }
    let(:data) do
      {
        title: item.title,
        author: item.author,
        barcode: item.barcode,
        isbn_issn: item.isbn_issn,
        bib_number: item.bib_number
      }
    end

    it 'sets expected values' do
      %i[
        title
        author
        barcode
        isbn_issn
        bib_number
      ].each do |field|
        expect(request.send(field)).to eq(data.fetch(field))
      end
    end

    it "calls NotifyError on an error and doesn't return a request" do
      expect_any_instance_of(Request).to receive(:save!).and_raise('error!')
      expect(NotifyError).to receive(:call).and_call_original
      expect(request).to be_nil
    end
  end
end
