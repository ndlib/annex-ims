require 'rails_helper'

RSpec.describe AssociateTrayWithItemBarcode do
  subject { AssociateTrayWithItemBarcode.call(@user.id, @tray, @item.barcode, @item.thickness)}

  before(:each) do

    @tray = FactoryGirl.create(:tray)
    @shelf = FactoryGirl.create(:shelf)
    @tray2 = FactoryGirl.create(:tray)
    @item = FactoryGirl.create(:item, tray: @tray)
    @item2 = FactoryGirl.create(:item)
    @user = FactoryGirl.create(:user)

    @uri = Addressable::URI.parse "http://1.0/resources/items/record?auth_token=&barcode=#{@item.barcode}"

    uri2 = Addressable::URI.parse "http://1.0/resources/items/stock?auth_token="

    stub_request(:get, @uri). with(:headers => {'User-Agent'=>'Faraday v0.9.1'}). to_return{ |response| { :status => 200, :body => {"item_id" => "00110147500410", "barcode" => @item.barcode, "bib_id" => @item.bib_number, "sequence_number" => "00410", "admin_document_number" => "001101475", "call_number" => @item.call_number, "description" => @item.chron ,"title"=> @item.title, "author" => @item.author ,"publication" => "Cambridge, UK : Elsevier Science Publishers, c1991-", "edition" => "", "isbn_issn" =>@item.isbn_issn, "condition" => @item.conditions}.to_json, :headers => {} } }

    stub_request(:post, uri2).
      with(:body => {"barcode"=>"#{@item.barcode}", "item_id"=>"#{@item.id}", "tray_code"=>"#{@tray.barcode}"},
        :headers => {'Content-Type'=>'application/x-www-form-urlencoded', 'User-Agent'=>'Faraday v0.9.1'}).
      to_return{ |response| { :status => 200, :body => {:results => {:status => "OK", :message => "Item stocked"}}.to_json, :headers => {} } }

    @user_id = 1 # Just fake having a user here
  end

  after(:each) do
    ActivityLog.all.each do |log|
      log.destroy!
    end
    Item.all.each do |item|
      item.destroy!
    end
    Tray.all.each do |tray|
      tray.destroy!
    end
  end

  it "gets an item from the barcode" do
    expect(GetItemFromBarcode).to receive(:call).with(@user.id, @item.barcode).and_return(@item)
    subject
  end

  it "sets the item" do
    expect(GetItemFromBarcode).to receive(:call).with(@user.id, @item.barcode).and_return(@item)
    expect(@item).to receive("tray=").with(@tray)
    subject
  end

  it "returns the item when it is successful" do
    expect(GetItemFromBarcode).to receive(:call).with(@user.id, @item.barcode).and_return(@item)
    stub_request(:get, @uri). with(:headers => {'User-Agent'=>'Faraday v0.9.1'}). to_return{ |response| { :status => 200, :body => {"item_id" => "00110147500410", "barcode" => @item.barcode, "bib_id" => @item.bib_number, "sequence_number" => "00410", "admin_document_number" => "001101475", "call_number" => @item.call_number, "description" => @item.chron ,"title"=> @item.title, "author" => @item.author ,"publication" => "Cambridge, UK : Elsevier Science Publishers, c1991-", "edition" => "", "isbn_issn" =>@item.isbn_issn, "condition" => @item.conditions}.to_json, :headers => {} } }
    allow(@item).to receive(:save).and_return(true)
    expect(subject).to eq(@item)
  end

  it "returns false when it is unsuccessful" do
    expect(GetItemFromBarcode).to receive(:call).with(@user.id, @item.barcode).and_return(@item)
    allow(@item).to receive("save!").and_return(false)
    expect(subject).to be_falsey
  end
end
