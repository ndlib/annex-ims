require 'sneakers/handlers/maxretry'

Sneakers.configure({
  handler: Sneakers::Handlers::Maxretry,
  amqp: Rails.application.secrets.sneakers["amqp"],
  vhost: Rails.application.secrets.sneakers["vhost"],
  workers: 1,
  heartbeat: 5,
  exchange: 'default',
  exchange_type: 'direct',
  routing_key: ['default'],
  durable: true,
  log: 'log/sneakers.log',
})
