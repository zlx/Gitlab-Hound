class JobQueue
  def self.push(job_class, *args)
    job_class.perform_async(*args)
  end
end
