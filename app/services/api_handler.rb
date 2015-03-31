class ApiHandler
  attr_reader :verb, :path, :headers, :params

  def self.call(verb, path, headers, params)
    new(verb, path, headers, params).transact!
  end

  def initialize(verb, path, headers, params)
    @connection ||= ExternalRestConnection.new(base_url: Rails.application.secrets.api_server, connection_opts: {})
    @verb = verb
    @path = path
    @headers = headers
    @params = params
  end

  def transact!
    @path << "?auth_token=#{Rails.application.secrets.api_token}"
    case @verb
    when "GET"
      @path << "&#{params}"
      @response = @connection.get(@path)
    when "POST"
      @response = @connection.post(@path, @headers, @params)
    else
      raise "Only GET and POST have been implemented."
    end

  end

end
