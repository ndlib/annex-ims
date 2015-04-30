class GetRequestsDataJob < ActiveJob::Base
  queue_as :default

  def perform(user_id)
Rails.logger.info "Got here"

      list = ApiGetRequestList.call(@user_id)

      if list["status"] == 200
        list["results"].each do |res|
          Request.where(trans: res["trans"]).first_or_create!(res) # ApiGetRequestList should return hashes suitable for creating requests. create also saves to db. I'm hoping that transaction is unique per request.
        end
      else
        raise "error getting request list"
      end
=begin
      data = ApiGetRequestList.call(user_id)
      if data["status"] == 200
        item.attributes = data["results"]
        item.thickness ||= 0
        item.save!
      elsif data["status"] == 404 # Not found
        AddIssue.call(user_id, barcode, "Item not found.")
        item.destroy!
        item = nil
      elsif data["status"] == 401 # Unauthorized - probably bad key
        AddIssue.call(user_id, barcode, "Unauthorized - Check API Key.")
        item = nil
      elsif data["status"] == 599 # Timeout
        AddIssue.call(user_id, barcode, "API Timeout.")
        item = nil
      end
=end
  end
end
