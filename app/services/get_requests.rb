class GetRequests
  def self.call(user_id)
    new(user_id).get_data!
  end

  def initialize(user_id)
    @user_id = user_id
  end

  def get_data!
    list = ApiGetRequestList.call(@user_id)

    if list["status"] == 200
      list["results"].each do |res|
        Request.where(trans: res["trans"]).first_or_create!(res) # ApiGetRequestList should return hashes suitable for creating requests. create also saves to db. I'm hoping that transaction is unique per request.
      end
    else
      raise "error getting request list"
    end
  end

end
