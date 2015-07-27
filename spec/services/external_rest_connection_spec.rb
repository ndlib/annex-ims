require "rails_helper"

RSpec.describe ExternalRestConnection do
  let(:base_url) { "http://example.com" }
  let(:connection_opts) { {} }
  let(:request_path) { "/test" }
  let(:request_body) { { body: "body" } }
  let(:response_body) { { test: "test" }.to_json }
  let(:response_status) { 200 }
  let(:expected_response_body) { JSON.parse(response_body) }
  let(:expected_response) { { status: response_status, results: expected_response_body } }
  let(:instance) { described_class.new(base_url: base_url, connection_opts: connection_opts) }

  subject { instance }

  describe "#timeout" do
    it "defaults to nil" do
      expect(subject.timeout).to be_nil
    end

    it "can be set to another value" do
      connection_opts[:timeout] = 3
      expect(subject.timeout).to eq(3)
    end
  end

  describe "#max_retries" do
    it "defaults to 2" do
      expect(subject.max_retries).to eq(2)
    end

    it "can be set to another value" do
      connection_opts[:max_retries] = 1
      expect(subject.max_retries).to eq(1)
    end
  end

  shared_examples "a request" do |method|
    context "success" do
      let(:response_status) { 200 }

      before do
        stub_request(method, File.join(base_url, request_path)).
          to_return(status: response_status, body: response_body)
      end

      it "makes a #{method} request" do
        expect(subject.send(method, *arguments)).to eq(expected_response)
      end

      it "uses the timeout value" do
        connection_opts[:timeout] = 1
        expect_any_instance_of(Faraday::RequestOptions).to receive(:timeout=).with(1)
        subject.send(method, *arguments)
      end
    end

    context "404 error" do
      let(:response_status) { 404 }
      let(:expected_response_body) { {} }

      before do
        stub_request(method, File.join(base_url, request_path)).
          with(body: request_body).
          to_return(status: response_status, body: response_body)
      end

      it "makes a #{method} request and returns an empty body" do
        expect(subject.send(method, *arguments)).to eq(expected_response)
      end
    end

    context "500 error" do
      let(:response_status) { 500 }
      let(:expected_response_body) { {} }

      before do
        stub_request(method, File.join(base_url, request_path)).
          with(body: request_body).
          to_return(status: response_status, body: response_body)
      end

      it "makes a #{method} request and returns an empty body" do
        expect(subject.send(method, *arguments)).to eq(expected_response)
      end
    end

    context "422 error" do
      let(:response_status) { 422 }

      before do
        stub_request(method, File.join(base_url, request_path)).
          with(body: request_body).
          to_return(status: response_status, body: response_body)
      end

      it "makes a #{method} request and returns body" do
        expect(subject.send(method, *arguments)).to eq(expected_response)
      end
    end
  end

  describe "#get" do
    let(:request_body) { nil }
    let(:arguments) { [request_path] }

    it_behaves_like "a request", :get
  end

  describe "#post" do
    let(:arguments) { [request_path, request_body] }

    it_behaves_like "a request", :post
  end

  describe "#put" do
    let(:arguments) { [request_path, request_body] }

    it_behaves_like "a request", :put
  end

  describe "#connection" do
    subject { instance.connection }

    it "returns a connection" do
      expect(subject).to be_a_kind_of(Faraday::Connection)
    end

    it "sets the adapter to Net::HTTP" do
      expect_any_instance_of(Faraday::Connection).to receive(:adapter).with(:net_http)
      subject
    end

    context "request" do
      before do
        allow_any_instance_of(Faraday::Connection).to receive(:request)
      end

      it "sets retry options" do
        expect_any_instance_of(Faraday::Connection).to receive(:request).with(:retry, instance.send(:request_retry_opts))
        subject
      end

      it "sets url_encoded" do
        expect_any_instance_of(Faraday::Connection).to receive(:request).with(:url_encoded)
        subject
      end
    end

    context "response" do
      before do
        allow_any_instance_of(Faraday::Connection).to receive(:response)
      end

      it "sets json response" do
        expect_any_instance_of(Faraday::Connection).to receive(:response).with(:json, content_type: /text\/plain/)
        subject
      end

      it "sets xml response" do
        expect_any_instance_of(Faraday::Connection).to receive(:response).with(:xml, content_type: /\bxml$/)
        subject
      end

      it "does not set caching if cache_response? is false" do
        expect(instance).to receive(:cache_response?).and_return(false)
        expect_any_instance_of(Faraday::Connection).to_not receive(:response).with(:caching, anything, anything)
        subject
      end

      it "sets caching if cache_response? is true" do
        expect(instance).to receive(:cache_response?).and_return(true)
        expect_any_instance_of(Faraday::Connection).to receive(:response).with(:caching, instance.send(:file_cache), ignore_params: %w(access_token))
        subject
      end
    end
  end

  describe "#file_cache" do
    it "returns a file cache object" do
      expect(subject.send(:file_cache)).to be_a_kind_of(ActiveSupport::Cache::FileStore)
    end
  end

  describe "#cache_response?" do
    it "returns false" do
      expect(subject.send(:cache_response?)).to eq(false)
    end
  end

  describe "#request_retry_opts" do
    it "returns retry options" do
      expect(subject).to receive(:max_retries).and_return(100)
      expect(subject.send(:request_retry_opts)).to eq(max: 100, interval: 0.05, interval_randomness: 1, backoff_factor: 2)
    end
  end
end
