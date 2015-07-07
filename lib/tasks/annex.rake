namespace :annex do
  desc "Retrieves active requests from the API and creates or updates local request records"
  task get_active_requests: :environment do
    begin
      logger = Logger.new(STDOUT)
      requests = GetRequests.call
      logger.info("[annex:get_active_requests] Retrieved #{requests.count} requests.")
    rescue StandardError => e
      NotifyError.call(exception: e)
      raise e
    end
  end
end
