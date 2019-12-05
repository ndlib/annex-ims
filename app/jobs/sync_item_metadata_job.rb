class SyncItemMetadataJob < ApplicationJob
  queue_as ItemMetadataWorker::QUEUE_NAME

  def perform(item:, user_id:)
    SyncItemMetadata.call(item: item, user_id: user_id, background: true)
  end
end
