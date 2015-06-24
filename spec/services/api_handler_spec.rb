require "rails_helper"

RSpec.describe ApiHandler do
  let(:response_status) { 200 }
  let(:raw_response) do
    {
      "status" => response_status,
      "results" => { "test" => "test" }
    }
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

  describe "#transact!" do
    it "creates an ApiHandler with the response" do
      expect(subject).to receive(:raw_transact!).and_return(raw_response)
      response = subject.transact!
      expect(response).to be_a_kind_of(ApiResponse)
      expect(response.status_code).to eq(200)
    end

    context "error" do
      let(:response_status) { 500 }

      it "returns the correct status code" do
        expect(subject).to receive(:raw_transact!).and_return(raw_response)
        expect(subject.transact!.status_code).to eq(500)
      end
    end

    it "handles a timeout exception" do
      expect(subject).to receive(:raw_transact!).and_raise(Timeout::Error)
      expect(subject.transact!.timeout?).to eq(true)
    end
  end

  context "GET" do
    it "calls #get on the connection and includes the params" do
      expect(connection).to receive(:get).with("#{path}?auth_token=#{auth_token}&#{params.to_param}").and_return(raw_response)
      subject.transact!
    end
  end

  context "POST" do
    let(:method) { "POST" }

    it "calls #post on the connection" do
      expect(connection).to receive(:post).with("#{path}?auth_token=#{auth_token}", params).and_return(raw_response)
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
