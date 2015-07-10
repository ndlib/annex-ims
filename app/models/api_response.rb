class ApiResponse
  attr_reader :status_code, :body

  def initialize(status_code:, body:)
    @status_code = status_code
    @body = body
    if @body.is_a?(Hash)
      @body = @body.with_indifferent_access
    end
  end

  def success?
    status_code == 200
  end

  def error?
    !success?
  end

  def not_found?
    status_code == 404
  end

  def timeout?
    status_code == 599
  end

  def unauthorized?
    status_code == 401
  end

  def attributes
    {
      status_code: status_code,
      body: body,
    }
  end
end
