class ApiGetRequestList
  def self.call()
    new().get_data!
  end

  def initialize
    @path = "/1.0/resources/items/active_requests"
  end

  def get_data!
    params = nil
    results = ApiHandler.call("GET", @path, params)

    if true
      results
    else
      false
    end
  end

end
