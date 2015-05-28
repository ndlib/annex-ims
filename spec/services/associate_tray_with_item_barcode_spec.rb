require 'rails_helper'

RSpec.describe AssociateTrayWithItemBarcode do
  subject { described_class.call(@user_id, @tray, @item.barcode, @item.thickness)}

  before(:each) do

    @tray = FactoryGirl.create(:tray)
    @shelf = FactoryGirl.create(:shelf)
    @tray2 = FactoryGirl.create(:tray)
    @item = FactoryGirl.create(:item)
    @item2 = FactoryGirl.create(:item)

    @template = Addressable::Template.new "#{Rails.application.secrets.api_server}/1.0/resources/items/record?auth_token=#{Rails.application.secrets.api_token}&barcode={barcode}"

    template2 = Addressable::Template.new "#{Rails.application.secrets.api_server}/1.0/resources/items/stock?auth_token=#{Rails.application.secrets.api_token}"

    stub_request(:get, @template). with(:headers => {'User-Agent'=>'Faraday v0.9.1'}). to_return{ |response| { :status => 200, :body => {"item_id" => "00110147500410", "barcode" => @item.barcode, "bib_id" => @item.bib_number, "sequence_number" => "00410", "admin_document_number" => "001101475", "call_number" => @item.call_number, "description" => @item.chron ,"title"=> @item.title, "author" => @item.author ,"publication" => "Cambridge, UK : Elsevier Science Publishers, c1991-", "edition" => "", "isbn_issn" =>@item.isbn_issn, "condition" => @item.conditions}.to_json, :headers => {} } }

    stub_request(:post, template2).
      with(:body => {"barcode"=>"#{@item.barcode}", "item_id"=>"#{@item.id}", "tray_code"=>"#{@tray.barcode}"},
        :headers => {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.9.1'}).
      to_return{ |response| { :status => 200, :body => {:results => {:status => "OK", :message => "Item stocked"}}.to_json, :headers => {} } }

    @user_id = 1 # Just fake having a user here
  end

  after(:each) do
    Item.all.each do |item|
      item.destroy!
    end
    Tray.all.each do |tray|
      tray.destroy!
    end
  end


  it "gets an item from the barcode" do
    expect(GetItemFromBarcode).to receive(:call).with(@user_id, @item.barcode).and_return(@item)
    subject
  end

  it "sets the item" do
    expect(@item).to receive("tray=").with(@tray)
    subject
  end

  it "returns the item when it is successful" do
    stub_request(:get, @template). with(:headers => {'User-Agent'=>'Faraday v0.9.1'}). to_return{ |response| { :status => 200, :body => {"item_id" => "00110147500410", "barcode" => @item.barcode, "bib_id" => @item.bib_number, "sequence_number" => "00410", "admin_document_number" => "001101475", "call_number" => @item.call_number, "description" => @item.chron ,"title"=> @item.title, "author" => @item.author ,"publication" => "Cambridge, UK : Elsevier Science Publishers, c1991-", "edition" => "", "isbn_issn" =>@item.isbn_issn, "condition" => @item.conditions}.to_json, :headers => {} } }
    allow(@item).to receive(:save).and_return(true)
    expect(subject).to eq(@item)
  end

  it "returns false when it is unsuccessful" do
    allow(@item).to receive("save!").and_return(false)
    expect(subject).to be(false)
  end


# this is not implemented in the class..
  it "raises an error if the item is not a tray." do
    #expect(IsTray).to recieve(:call).with(tray).and_return(false)
    #expect { subject }.to raise_error
  end
end
