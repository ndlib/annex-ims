require "rails_helper"

RSpec.describe BinsController, type: :controller do
  let(:shelf) { FactoryGirl.create(:shelf) }
  let(:tray) { FactoryGirl.create(:tray, shelf: shelf) }
  let(:item) { FactoryGirl.create(:item, tray: tray, thickness: 1) }
  let(:bin) { FactoryGirl.create(:bin, items: [item]) }
  let(:match) { FactoryGirl.create(:match, item: item, bin: bin, request: request) }
  let(:user) { FactoryGirl.create(:user, admin: true) }
  let(:request) { FactoryGirl.create(:request, del_type: "loan") }

  before(:each) do
    sign_in(user)
  end

  describe "remove" do
    let(:subject) { post :remove_match, match_id: match.id }

    it "uses DestroyMatch" do
      expect(DestroyMatch).to receive(:call).with(match: match, user: user)
      subject
    end

    it "flashes a message when there are remaining matches associated with the item" do
      request2 = FactoryGirl.create(:request, del_type: "loan")
      FactoryGirl.create(:match, item: item, bin: bin, request: request2)
      subject
      expect(flash[:warning]).to be_present
    end

    it "redirects back to show" do
      expect(subject).to redirect_to show_bin_path(id: bin.id)
    end
  end

  describe "process" do
    let(:subject) { post :process_match, match_id: match.id }

    it "uses ProcessMatch" do
      expect(ProcessMatch).to receive(:call).with(match: match, user: user)
      subject
    end

    it "flashes a message when there are remaining matches associated with the item" do
      request2 = FactoryGirl.create(:request, del_type: "loan")
      FactoryGirl.create(:match, item: item, bin: bin, request: request2)
      subject
      expect(flash[:warning]).to be_present
    end

    it "redirects back to show" do
      expect(subject).to redirect_to show_bin_path(id: bin.id)
    end
  end
end
