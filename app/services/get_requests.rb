class GetRequests
  def self.call(user_id)
    new(user_id).get_data!
  end

  def initialize(user_id)
    @user_id = user_id
  end

  def get_data!
    response = ApiGetRequestList.call(@user_id)

    if response.success?
      response.body.each do |res|
        r = Request.find_or_initialize_by(trans: res["trans"])
        r.attributes = res
        r.save!
      end
    else
      raise "error getting request list"
    end
  end

end
