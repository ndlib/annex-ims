require "rails_helper"

RSpec.describe ApiHandler do
  let(:response_status) { 200 }
  let(:raw_response) do
    {
      status: response_status,
      results: { "test" => "test" }
    }
  end

  let(:auth_token) { Rails.application.secrets.api_token }
  let(:method) { "GET" }
  let(:expected_path) { "/1.0/resources/items/#{action}" }
  let(:action) { :test }
  let(:params) { { test: "test" } }
  let(:connection) { instance_double(ExternalRestConnection) }

  subject { described_class.new(verb: method, action: action, params: params) }

  before do
    allow(ExternalRestConnection).to receive(:new).and_return(connection)
  end

  context "self" do
    subject { described_class }

    describe "#call" do
      it "instantiates a new record and calls transact!" do
        expect(described_class).to receive(:new).with(verb: "GET", action: action, params: params, connection_opts: {}).and_call_original
        expect_any_instance_of(described_class).to receive(:transact!).and_return("response")
        expect(subject.call(verb: "GET", action: action, params: params)).to eq("response")
      end

      it "sends the connection_opts" do
        expect(described_class).to receive(:new).with(verb: "GET", action: action, params: params, connection_opts: { timeout: 3 }).and_call_original
        expect_any_instance_of(described_class).to receive(:transact!)
        expect(subject.call(verb: "GET", action: action, params: params, connection_opts: { timeout: 3 }))
      end
    end

    describe "#get" do
      it "calls #call with GET" do
        expect(described_class).to receive(:call).with(verb: "GET", action: action, params: params, connection_opts: {}).and_return("response")
        expect(subject.get(action: action, params: params)).to eq("response")
      end
    end

    describe "#post" do
      it "calls #call with POST" do
        expect(described_class).to receive(:call).with(verb: "POST", action: action, params: params, connection_opts: {}).and_return("response")
        expect(subject.post(action: action, params: params)).to eq("response")
      end
    end

    describe "#base_url" do
      it "returns the api url" do
        expect(subject.base_url).to eq(Rails.application.secrets.api_server)
      end
    end

    describe "#path" do
      it "returns the path with the auth token" do
        expect(subject.path(action)).to eq("#{expected_path}?auth_token=#{auth_token}")
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

    context "timeout" do
      let(:error_arguments) do
        {
          exception: kind_of(Timeout::Error),
          parameters: { action: action, params: params },
          component: described_class.to_s,
          action: "transact!"
        }
      end

      it "handles a timeout exception" do
        expect(subject).to receive(:raw_transact!).and_raise(Timeout::Error)
        expect(NotifyError).to receive(:call).with(error_arguments)
        expect(subject.transact!.timeout?).to eq(true)
      end

      it "handles a faraday timeout" do
        stub_request(:get, api_url(action, params)).to_raise(Faraday::TimeoutError)
        expect(ExternalRestConnection).to receive(:new).and_call_original
        error_arguments[:exception] = kind_of(Faraday::TimeoutError)
        expect(NotifyError).to receive(:call).with(error_arguments)
        expect(subject.transact!.timeout?).to eq(true)
      end
    end
  end

  context "with connection_opts" do
    subject { described_class.new(verb: method, action: action, params: params, connection_opts: { timeout: 3 }) }

    it "sends connection_opts to the connection" do
      expect(ExternalRestConnection).to receive(:new).with(base_url: anything, connection_opts: { timeout: 3 }).and_return(connection)
      expect(subject.send(:connection)).to eq(connection)
    end
  end

  context "GET" do
    it "calls #get on the connection and includes the params" do
      expect(connection).to receive(:get).with("#{expected_path}?auth_token=#{auth_token}&#{params.to_param}").and_return(raw_response)
      subject.transact!
    end
  end

  context "POST" do
    let(:method) { "POST" }

    it "calls #post on the connection" do
      expect(connection).to receive(:post).with("#{expected_path}?auth_token=#{auth_token}", params).and_return(raw_response)
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
