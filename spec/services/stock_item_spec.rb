require 'rails_helper'

RSpec.describe StockItem do
  subject { described_class.call(@item, @user)}

  before(:each) do
    @tray = FactoryGirl.create(:tray)
    @shelf = FactoryGirl.create(:shelf)
    @tray2 = FactoryGirl.create(:tray)
    @item = FactoryGirl.create(:item, tray: @tray, thickness: 1)
    @item2 = FactoryGirl.create(:item, thickness: 1)
    @user = FactoryGirl.create(:user)

    template = Addressable::Template.new "#{Rails.application.secrets.api_server}/1.0/resources/items/record?auth_token=#{Rails.application.secrets.api_token}&barcode={barcode}"

    template2 = Addressable::Template.new "#{Rails.application.secrets.api_server}/1.0/resources/items/stock?auth_token=#{Rails.application.secrets.api_token}"

    stub_request(:get, template). with(:headers => {'User-Agent'=>'Faraday v0.9.1'}). to_return(:status => 200, :body => '{"item_id":"00110147500410","barcode":"00000016021933","bib_id":"001101475","sequence_number":"00410","admin_document_number":"001101475","call_number":"QH 573 .T746","description":"v.11 :no.1-6  \u003Cp.1-276\u003E   (2001:Jan.-June)","title":"Trends in cell biology.","author":"","publication":"Cambridge, UK : Elsevier Science Publishers, c1991-","edition":"","isbn_issn":"0962-8924","condition":null}', :headers => {})

    stub_request(:post, template2).
      with(:body => {"barcode"=>"#{@item.barcode}", "item_id"=>"#{@item.id}", "tray_code"=>"#{@item.tray.barcode}"},
        :headers => {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.9.1'}).
      to_return{ |response| { :status => 200, :body => {:results => {:status => "OK", :message => "Item stocked"}}.to_json, :headers => {} } }
  end

  it "sets stocked" do
    expect(@item).to receive("stocked!")
    subject
  end

  it "returns the item when it is successful" do
    allow(@item).to receive(:save).and_return(true)
    expect(subject).to be(@item)
  end

  it "returns false when it is unsuccessful" do
    allow(@item).to receive("save!").and_return(false)
    expect(subject).to be(false)
  end

end
