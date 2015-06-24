class ApiHandler
  attr_reader :verb, :base_path, :params, :response

  class HTTPMethodNotImplemented < StandardError; end

  def self.call(verb, base_path, params)
    new(verb, base_path, params).transact!
  end

  def self.get(base_path, params)
    call("GET", base_path, params)
  end

  def self.post(base_path, params)
    call("POST", base_path, params)
  end

  def initialize(verb, base_path, params)
    @verb = verb
    @base_path = base_path
    @params = params
  end

  def transact!
    case verb
    when "GET"
      @response = connection.get(path_with_params)
    when "POST"
      @response = connection.post(path, params)
    else
      raise HTTPMethodNotImplemented, "Only GET and POST have been implemented."
    end
  end

  private

  def connection
    @connection ||= ExternalRestConnection.new(base_url: base_url, connection_opts: {})
  end

  def auth_token_param
    { auth_token: auth_token }.to_param
  end

  def path
    "#{base_path}?#{auth_token_param}"
  end

  def path_with_params
    "#{path}&#{params.to_param}"
  end

  def auth_token
    Rails.application.secrets.api_token
  end

  def base_url
    Rails.application.secrets.api_server
  end

end
