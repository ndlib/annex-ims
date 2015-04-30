class GetRequests
  def self.call(user_id)
    new(user_id).get_data!
  end

  def initialize(user_id)
    @user_id = user_id
  end

  def get_data!

    GetRequestsDataJob.perform_later(@user_id)

  end

end
