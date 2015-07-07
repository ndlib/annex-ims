namespace :annex do
  desc "Retrieves active requests from the API and creates or updates local request records"
  task get_active_requests: :environment do
    begin
      logger = Logger.new(STDOUT)
      requests = GetRequests.call
      message = I18n.t("requests.synchronized", count: requests.count)
      logger.info("[annex:get_active_requests] #{message}")
    rescue StandardError => e
      NotifyError.call(exception: e)
      raise e
    end
  end
end
