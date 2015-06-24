require "rails_helper"

class DefaultsWorker < RetryWorker
  from_queue "testdefaults"
end

RSpec.describe RetryWorker, type: :worker do
  subject { described_class.new }

  let (:queue) { subject.queue }

  let (:queue_options) { queue.opts.to_hash }

  describe "self" do
    subject { described_class }

    describe "#number_of_workers" do
      it "defaults to 1" do
        expect(subject.number_of_workers).to eq(1)
      end
    end
  end

  describe "defaults" do
    subject { DefaultsWorker.new }

    it "uses the correct queue name" do
      expect(queue.name).to eq("testdefaults")
    end

    it "sets the correct queue options" do
      expect(queue_options[:arguments]).to eq(:"x-dead-letter-exchange" => "testdefaults-retry")
      expect(queue_options[:handler]).to eq(Sneakers::Handlers::Maxretry)
      expect(queue_options[:routing_key]).to eq(["testdefaults"])
    end
  end
end
