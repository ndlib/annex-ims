class ApiScanSendJob < ActiveJob::Base
  queue_as ApiWorker::QUEUE_NAME

  def perform(match:)
    ApiPostDeliverItem.call(match: match)
  end
end
