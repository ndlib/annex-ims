class SyncItemMetadataJob < ActiveJob::Base
  queue_as ItemMetadataWorker::QUEUE_NAME

  def perform(item:, user_id:)
    SyncItemMetadata.call(item: item, user_id: user_id)
  end
end
