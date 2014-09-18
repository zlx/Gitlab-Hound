class JobQueue
  def self.push(job_class, *args)
    job_class.new.perform(*args)
  end
end
