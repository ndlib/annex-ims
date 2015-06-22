class PostDeliverDataJob < ActiveJob::Base
  queue_as :default

  def perform(user_id, match_id)
    user = User.find(user_id)
    data = ApiPostDeliverItem.call(match_id, user)

    if data["status"] == 200
      # carry on, this is normal
    elsif data["status"] == 404 # Not found
      AddIssue.call(user_id, barcode, "Item not found.")
    elsif data["status"] == 401 # Unauthorized - probably bad key
      AddIssue.call(user_id, barcode, "Unauthorized - Check API Key.")
    elsif data["status"] == 599 # Timeout
      AddIssue.call(user_id, barcode, "API Timeout.")
    end

  end

end
