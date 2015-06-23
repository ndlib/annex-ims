class ItemMetadataWorker < RetryWorker
  WORKERS = 4

  from_queue "annex_item_metadata",
             threads: 1,
             timeout_job_after: 60,
             prefetch: 1
end
