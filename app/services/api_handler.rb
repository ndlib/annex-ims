class ApiHandler
  BASE_PATH = "/1.0/resources/items"

  attr_reader :verb, :action, :params, :response

  class HTTPMethodNotImplemented < StandardError; end

  def self.call(verb:, action:, params: {})
    new(verb: verb, action: action, params: params).transact!
  end

  def self.get(action:, params: {})
    call(verb: "GET", action: action, params: params)
  end

  def self.post(action:, params: {})
    call(verb: "POST", action: action, params: params)
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

  def initialize(verb:, action:, params: {})
    @verb = verb
    @action = action
    @params = params
  end

  def transact!
    raw_response = raw_transact!
    ApiResponse.new(status_code: raw_response["status"], body: raw_response["results"])
  rescue Timeout::Error => e
    NotifyError.call(exception: e)
    ApiResponse.new(status_code: 599, body: {})
  end

  private

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
    @connection ||= ExternalRestConnection.new(base_url: base_url, connection_opts: {})
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
