class ApiHandler
  attr_reader :verb, :path, :params

  def self.call(verb, path, params)
    new(verb, path, params).transact!
  end

  def initialize(verb, path, params)
    @connection ||= ExternalRestConnection.new(base_url: Rails.application.secrets.api_server, connection_opts: {})
    @verb = verb
    @path = path
    @params = params
  end

  def transact!
    @path << "?auth_token=#{Rails.application.secrets.api_token}"
    case @verb
    when "GET"
      @path << "&#{params}"
      @response = @connection.get(@path)
    when "POST"
      @response = @connection.post(@path, @params)
    else
      raise "Only GET and POST have been implemented."
    end

  end

end
