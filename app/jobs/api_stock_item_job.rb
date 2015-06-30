class ApiStockItemJob < ActiveJob::Base
  queue_as ApiWorker::QUEUE_NAME

  def perform(item:)
    ApiPostStockItem.call(item: item)
  end
end
