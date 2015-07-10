require "rails_helper"

RSpec.describe ActivityLogQuery do
  let!(:item_1) { FactoryGirl.create(:item) }
  let!(:item_2) { FactoryGirl.create(:item) }
  let!(:item_3) { FactoryGirl.create(:item) }
  let!(:tray_1) { FactoryGirl.create(:tray) }
  let!(:tray_2) { FactoryGirl.create(:tray) }
  let!(:batch) { FactoryGirl.create(:batch) }
  let!(:request_1) { FactoryGirl.create(:request, requested: 2.days.ago) }
  let!(:request_2) { FactoryGirl.create(:request, requested: 1.day.ago) }
  let!(:request_3) { FactoryGirl.create(:request) }
  let!(:match_1) { FactoryGirl.create(:match, batch: batch, request: request_1, item: item_1) }
  let!(:match_2) { FactoryGirl.create(:match, batch: batch, request: request_1, item: item_2) }
  let!(:match_3) { FactoryGirl.create(:match, batch: batch, request: request_1, item: item_3) }
  let!(:match_4) { FactoryGirl.create(:match, batch: batch, request: request_2, item: item_1) }
  let!(:user) { FactoryGirl.create(:user) }
  subject { ActivityLogQuery }

  context "item shipped" do
    describe "#item_usage" do
      before(:each) do
        ActivityLogger.ship_item(item: item_1, request: request_1, user: user)
        ActivityLogger.ship_item(item: item_2, request: request_2, user: user)
        ActivityLogger.ship_item(item: item_2, request: request_3, user: user)
      end

      it "returns correct number of shipped logs" do
        expect(subject.item_usage(item_2).count).to eq 2
        expect(subject.item_usage(item_1).count).to eq 1
      end

      it "returns the logs in chronological order" do
        expect(subject.item_usage(item_2).first.data["request"]["id"]).to eq request_3.id
      end
    end
  end

  context "item stocked" do
    describe "#item_history" do
      before(:each) do
        ActivityLogger.stock_item(item: item_1, tray: tray_1, user: user)
        ActivityLogger.stock_item(item: item_1, tray: tray_2, user: user)
        ActivityLogger.stock_item(item: item_2, tray: tray_2, user: user)
        ActivityLogger.stock_item(item: item_3, tray: tray_1, user: user)
      end

      it "returns correct number of item stocked logs" do
        expect(subject.item_history(item_2).count).to eq 1
        expect(subject.item_history(item_1).count).to eq 2
      end

      it "returns the logs in chronological order" do
        expect(subject.item_history(item_1)[1].data["tray"]["id"]).to eq tray_1.id
      end
    end
  end
end
