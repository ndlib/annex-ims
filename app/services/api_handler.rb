class ApiHandler
  BASE_PATH = "/1.0/resources/items"

  attr_reader :verb, :action, :params, :response, :connection_opts

  class HTTPMethodNotImplemented < StandardError; end

  def self.call(verb:, action:, params: {}, connection_opts: {})
    new(verb: verb, action: action, params: params, connection_opts: connection_opts).transact!
  end

  def self.get(action:, params: {}, connection_opts: {})
    call(verb: "GET", action: action, params: params, connection_opts: connection_opts)
  end

  def self.post(action:, params: {}, connection_opts: {})
    call(verb: "POST", action: action, params: params, connection_opts: connection_opts)
  end

  def self.path(action)
    "#{File.join(BASE_PATH, action.to_s)}?#{auth_token_param}"
  end

  def self.auth_token
    Rails.application.secrets.api_token
  end

  def self.auth_token_param
    { auth_token: auth_token }.to_param
  end

  def self.base_url
    Rails.application.secrets.api_server
  end

  def initialize(verb:, action:, params: {}, connection_opts: {})
    @verb = verb
    @action = action
    @params = params
    @connection_opts = connection_opts
  end

  def transact!
    raw_response = raw_transact!
    ApiResponse.new(status_code: raw_response["status"], body: raw_response["results"])
  rescue Timeout::Error => e
    handle_timeout_exception(e)
  rescue Faraday::TimeoutError => e
    handle_timeout_exception(e)
  end

  private

  def handle_timeout_exception(exception)
    NotifyError.call(exception: exception)
    ApiResponse.new(status_code: 599, body: {})
  end

  def raw_transact!
    case verb
    when "GET"
      connection.get(path_with_params)
    when "POST"
      connection.post(path, params)
    else
      raise HTTPMethodNotImplemented, "Only GET and POST have been implemented."
    end
  end

  def connection
    @connection ||= ExternalRestConnection.new(base_url: base_url, connection_opts: connection_opts)
  end

  def path
    self.class.path(action)
  end

  def base_url
    self.class.base_url
  end

  def path_with_params
    "#{path}&#{params.to_param}"
  end

end
