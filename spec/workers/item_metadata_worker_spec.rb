require "rails_helper"

RSpec.describe ItemMetadataWorker, type: :worker do
  subject { described_class.new }

  let (:queue) { subject.queue }

  let (:queue_options) { queue.opts.to_hash }

  describe "self" do
    subject { described_class }

    describe "#number_of_workers" do
      it "is 1" do
        expect(subject.number_of_workers).to eq(1)
      end
    end
  end

  describe "queue" do
    it "uses the correct queue name" do
      expect(queue.name).to eq("annex_item_metadata")
    end

    it "sets the correct queue options" do
      expect(queue_options[:arguments]).to eq(:"x-dead-letter-exchange" => "annex_item_metadata-retry")
      expect(queue_options[:handler]).to eq(Sneakers::Handlers::Maxretry)
      expect(queue_options[:routing_key]).to eq(["annex_item_metadata"])
      expect(queue_options[:threads]).to eq(1)
      expect(queue_options[:timeout_job_after]).to eq(60)
      expect(queue_options[:prefetch]).to eq(1)
    end
  end
end
