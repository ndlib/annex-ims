require "rails_helper"

RSpec.describe BuildTransfer do
  let(:shelf) { Shelf.new(barcode: "SHELF-abc-123") }
  let(:shelf2) { Shelf.new(barcode: "SHELF-def-456") }
  let(:user) { User.new(username: "foobar") }
  let(:user2) { User.new(username: "barfoo") }
  let(:transfer) { Transfer.new(shelf: shelf, initiated_by: user, transfer_type: "ShelfTransfer") }

  context "when the transfer batch has been created previously" do
    describe "#call" do
      subject { BuildTransfer.call(shelf, user) }

      it "initializes a transfer object" do
        expect(BuildTransfer).to receive(:retrieve_transfer).at_least(:once).and_return(transfer)
        expect(subject).to be_a_kind_of(Transfer)
      end

      it "calls build!" do
        expect_any_instance_of(described_class).to receive(:build!).at_least(:once)
        subject
      end

      it "initializes the shelf object" do
        expect(BuildTransfer).to receive(:retrieve_transfer).at_least(:once).and_return(transfer)
        expect(subject.shelf.barcode).to eq "SHELF-abc-123"
      end

      it "initializes the user object" do
        expect(BuildTransfer).to receive(:retrieve_transfer).at_least(:once).and_return(transfer)
        expect(subject.initiated_by.username).to eq "foobar"
      end
    end
  end

  context "when the transfer batch is new" do
    describe "#call" do
      subject { BuildTransfer.call(shelf2, user2) }

      it "initializes a transfer object" do
        expect(BuildTransfer).to receive(:retrieve_transfer).at_least(:once).and_return(nil)
        expect(subject).to be_a_kind_of(Transfer)
      end

      it "calls build!" do
        expect_any_instance_of(described_class).to receive(:build!).at_least(:once)
        subject
      end

      it "initializes the shelf object" do
        expect(BuildTransfer).to receive(:retrieve_transfer).at_least(:once).and_return(nil)
        expect(subject.shelf.barcode).to eq "SHELF-def-456"
        expect(subject.shelf.id).to eq Shelf.last.id
      end

      it "initializes the user object" do
        expect(BuildTransfer).to receive(:retrieve_transfer).at_least(:once).and_return(nil)
        expect(subject.initiated_by.username).to eq "barfoo"
        expect(subject.initiated_by.id).to eq User.last.id
      end
    end
  end
end
