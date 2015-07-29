# class for establishing a rest connection to an external source
class ExternalRestConnection
  DEFAULT_CONNECTION_OPTIONS = {
    max_retries: Rails.configuration.settings.api_max_retries,
    timeout: nil
  }.freeze

  attr_reader :base_url, :connection, :opts, :response

  def initialize(base_url: nil, connection_opts: {})
    @opts = DEFAULT_CONNECTION_OPTIONS.merge(connection_opts)
    @base_url = base_url
  end

  def max_retries
    opts.fetch(:max_retries)
  end

  def timeout
    opts.fetch(:timeout)
  end

  # GET verb
  def get(path)
    make_request(method: :get, path: path)
  end

  # PUT verb
  def put(path, body)
    make_request(method: :put, path: path, body: body)
  end

  # POST verb
  def post(path, body)
    make_request(method: :post, path: path, body: body)
  end

  def connection
    @connection ||= establish_connection
  end

  private

  def make_request(method:, path:, body: nil)
    @response = connection.send(method) do |req|
      req.url path
      if body
        req.body = body
      end
      if timeout
        req.options.timeout = timeout
      end
    end
    process_response
  end

  def establish_connection
    Faraday.new(url: base_url) do |conn|
      setup_connection(conn)
    end
  end

  def setup_connection(new_connection)
    new_connection.request :retry, request_retry_opts
    new_connection.request :url_encoded
    new_connection.response :json, content_type: /text\/plain/
    new_connection.response :xml, content_type: /\bxml$/
    if cache_response?
      new_connection.response :caching, file_cache, ignore_params: %w(access_token)
    end
    new_connection.adapter :net_http
  end

  def cache_response?
    false
  end

  def file_cache
    @file_cache ||= ActiveSupport::Cache::FileStore.new(
      File.join(rails_root, "/tmp", "cache"),
      namespace: "api_rest_data",
      expires_in: 240)
  end

  def rails_root
    Rails.root
  end

  def request_retry_opts
    {
      max: max_retries,
      interval: 0.05,
      interval_randomness: 1,
      backoff_factor: 2
    }
  end

  def process_response
    result = { status: response.status }
    response.status == (200 || 422) ? result[:results] = JSON.parse(response.body) : result[:results] = {}
    result
  end
end
