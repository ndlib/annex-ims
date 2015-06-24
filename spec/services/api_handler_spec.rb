require "rails_helper"

RSpec.describe ApiHandler do
  let(:raw_response) do
    ""
  end

  let(:auth_token) { Rails.application.secrets.api_token }
  let(:method) { "GET" }
  let(:path) { "1.0/test" }
  let(:params) { { test: "test" } }
  let(:connection) { instance_double(ExternalRestConnection) }

  subject { described_class.new(method, path, params) }

  before do
    allow(ExternalRestConnection).to receive(:new).and_return(connection)
  end

  context "self" do
    subject { described_class }

    describe "#call" do
      it "instantiates a new record and calls transact!" do
        expect(described_class).to receive(:new).with("GET", path, params).and_call_original
        expect_any_instance_of(described_class).to receive(:transact!).and_return("response")
        expect(subject.call("GET", path, params)).to eq("response")
      end
    end

    describe "#get" do
      it "calls #call with GET" do
        expect(described_class).to receive(:call).with("GET", path, params).and_return("response")
        expect(subject.get(path, params)).to eq("response")
      end
    end

    describe "#post" do
      it "calls #call with POST" do
        expect(described_class).to receive(:call).with("POST", path, params).and_return("response")
        expect(subject.post(path, params)).to eq("response")
      end
    end
  end

  context "GET" do
    it "calls #get on the connection and includes the params" do
      expect(connection).to receive(:get).with("#{path}?auth_token=#{auth_token}&#{params.to_param}")
      subject.transact!
    end
  end

  context "POST" do
    let(:method) { "POST" }

    it "calls #post on the connection" do
      expect(connection).to receive(:post).with("#{path}?auth_token=#{auth_token}", params)
      subject.transact!
    end
  end

  context "PUT" do
    let(:method) { "PUT" }

    it "raises an error" do
      expect { subject.transact! }.to raise_error(described_class::HTTPMethodNotImplemented)
    end
  end
end
