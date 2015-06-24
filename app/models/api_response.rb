class ApiResponse
  attr_reader :status_code, :body

  def initialize(status_code: status_code, body: body)
    @status_code = status_code
    @body = body.with_indifferent_access
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
end
