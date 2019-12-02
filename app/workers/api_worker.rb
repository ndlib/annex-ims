class ApiWorker < RetryWorker
  WORKERS = 1
  QUEUE_NAME = "annex_api".freeze

  from_queue QUEUE_NAME,
             threads: 1,
             timeout_job_after: 60,
             prefetch: 1
end
