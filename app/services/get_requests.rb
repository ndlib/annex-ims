class GetRequests
  def self.call()
    new().get_data!
  end

  def get_data!
    list = ApiGetRequestList.call()

    if list["status"] == 200
      list["results"].each do |res|
        Request.where(trans: res["trans"]).first_or_create!(res) # ApiGetRequestList should return hashes suitable for creating requests. create also saves to db. I'm hoping that transaction is unique per request.
      end
    else
      raise "error getting request list"
    end
  end

end
