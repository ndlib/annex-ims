require "rails_helper"

RSpec.describe TraysController, :type => :controller do
  let(:user) { FactoryGirl.create(:user, admin: true) }

  before(:each) do
    sign_in(user)
  end

  describe "GET index" do
    context "admin" do
      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end

    context "worker" do
      let(:user) { FactoryGirl.create(:user, worker: true) }

      it "returns http success" do
        get :index
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST scan" do
    context "admin" do
      it "redirects" do
        post :scan, tray: { barcode: "TRAY-AL123" }
        expect(response).to be_redirect
        expect(response.location).to match(/trays\/shelves\/\d+/)
      end

      it "calls notify_airbrake on error and redirects to the trays path" do
        expect(controller).to receive(:notify_airbrake).with(kind_of(RuntimeError))
        post :scan, tray: { barcode: "12345" }
        expect(response).to redirect_to(trays_path)
      end
    end

    context "worker" do
      let(:user) { FactoryGirl.create(:user, worker: true) }

      it "redirects" do
        post :scan, tray: { barcode: "TRAY-AL123" }
        expect(response).to be_redirect
        expect(response.location).to match(/trays\/shelves\/\d+/)
      end

      it "calls notify_airbrake on error and redirects to the trays path" do
        expect(controller).to receive(:notify_airbrake).with(kind_of(RuntimeError))
        post :scan, tray: { barcode: "12345" }
        expect(response).to redirect_to(trays_path)
      end
    end
  end

  describe "GET check_items_new" do
    subject { get :check_items_new }

    it "returns http success" do
      subject
      expect(response).to have_http_status(:success)
    end

    it "assigns tray for the view" do
      subject
      expect(assigns(:tray)).not_to eq(nil)
    end
  end

  describe "GET check_items" do
    subject { get :check_items, tray: { barcode: "12345" } }

    it "returns http success" do
      subject
      expect(response).to have_http_status(:success)
    end

    it "finds and assigns tray for the view" do
      allow(Tray).to receive(:where).with(barcode: "12345").and_return(double(Object, take: "tray"))
      subject
      expect(assigns(:tray)).to eq("tray")
    end

    it "assigns scanned for the view" do
      subject
      expect(assigns(:scanned)).to eq([])
    end
  end

  describe "POST validate_items" do
    let(:tray) { instance_double(Tray, items: [item], barcode: "tray barcode") }
    let(:item) { instance_double(Item, save!: true) }
    subject { post :validate_items, id: 1, barcode: "barcode" }

    before(:each) do
      allow(Tray).to receive(:find).and_return(tray)
    end

    it "returns http success" do
      subject
      expect(response).to have_http_status(:success)
    end

    it "finds and assigns tray for the view" do
      subject
      expect(assigns(:tray)).to eq(tray)
    end

    it "assigns scanned for the view" do
      subject
      expect(assigns(:scanned)).to eq([])
    end

    it "renders check_items" do
      expect(subject).to render_template(:check_items)
    end

    context "for an invalid barcode" do
      it "flashes an error" do
        post :validate_items, id: 1, barcode: "invalid barcode"
        expect(flash[:error]).to include("invalid barcode")
      end
    end

    context "for a valid barcode thats not found" do
      subject { post :validate_items, id: 1, barcode: "valid barcode" }

      before(:each) do
        allow(IsValidItem).to receive(:call).and_return(true)
        allow(ActivityLogger).to receive(:create_item)
        allow(AddIssue).to receive(:call)
        allow(SyncItemMetadata).to receive(:call)
        allow(Item).to receive(:new).and_return(item)
      end

      it "creates a new item" do
        expect(Item).to receive(:new).and_return(item)
        expect(item).to receive(:save!).and_return(true)
        subject
      end

      it "logs a create item" do
        expect(ActivityLogger).to receive(:create_item).with(item: item, user: user)
        subject
      end

      it "adds a tray_mismatch issue" do
        expect(AddIssue).to receive(:call).
          with(item: item, user: user, type: "tray_mismatch", message: anything)
        subject
      end

      it "syncs metadata" do
        expect(SyncItemMetadata).to receive(:call).with(item: item, user_id: user.id)
        subject
      end

      it "flashes an error" do
        subject
        expect(flash[:error]).to include("valid barcode")
      end
    end

    context "for a valid item that's not associated with the tray" do
      let(:tray) { instance_double(Tray, items: [], barcode: "tray barcode") }
      let(:other_tray) { instance_double(Tray, barcode: "other tray barcode") }
      let(:item) { instance_double(Item, tray: tray) }
      subject { post :validate_items, id: 1, barcode: "valid item barcode" }

      before(:each) do
        allow(Item).to receive(:where).and_return(double(Object, take: item))
        allow(AddIssue).to receive(:call)
      end

      it "flashes an error" do
        subject
        expect(flash[:error]).to include("valid item barcode")
      end

      it "adds a tray_mismatch issue when it is not associated with a tray" do
        allow(item).to receive(:tray).and_return nil
        expect(AddIssue).to receive(:call).
          with(item: item, user: user, type: "tray_mismatch", message: /tray barcode/)
        subject
      end

      it "adds a tray_mismatch issue with the tray it is associated with" do
        allow(item).to receive(:tray).and_return other_tray
        expect(AddIssue).to receive(:call).
          with(item: item, user: user, type: "tray_mismatch", message: /tray barcode.*other tray barcode/)
        subject
      end
    end

    context "for a valid item that is associated to the tray" do
      let(:tray) { instance_double(Tray, items: [item], barcode: "tray barcode") }
      let(:item) { instance_double(Item) }
      subject { post :validate_items, id: 1, barcode: "valid item barcode" }

      before(:each) do
        allow(Item).to receive(:where).and_return(double(Object, take: item))
      end

      it "adds the item's barcode to the scanned list" do
        subject
        expect(assigns(:scanned)).to eq(["valid item barcode"])
      end
    end
  end
end
