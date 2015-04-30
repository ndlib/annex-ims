require 'sneakers/handlers/maxretry'

class ItemDataWorker < ActiveJob::QueueAdapters::SneakersAdapter::JobWrapper
  from_queue 'default',
    handler: Sneakers::Handlers::Maxretry,
    workers: 1,
    threads: 1,
    timeout_job_after: 60,
    heartbeat_interval: 2,
    prefetch: 1,
    ack: true,
    arguments: {
      :'x-dead-letter-exchange' => 'default-retry',
    },
    routing_key: ['default']

  def work(*args)
    logger.info("ItemDataWorker rejecting args: #{args.inspect}")
    begin
      super(*args)
    rescue Exception => e
      Airbrake.notify(e, parameters: {args: args})
      reject!
    end
  end
end
