class ApiDeaccessionItemJob < ActiveJob::Base
  queue_as ApiWorker::QUEUE_NAME

  def perform(item:)
    ApiPostDeaccessionItem.call(item: item)
  end
end
