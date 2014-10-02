RAILS_ROOT = File.expand_path("../..", __FILE__)
ENV["RACK_ENV"] = ENV["RAILS_ENV"] ||= "production"
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)
timeout 15
preload_app true
listen "#{RAILS_ROOT}/tmp/sockets/unicorn.sock"
pid "#{RAILS_ROOT}/tmp/pids/unicorn.pid"
stderr_path "#{RAILS_ROOT}/log/unicorn.err.log"
stdout_path "#{RAILS_ROOT}/log/unicorn.out.log"

before_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection.disconnect!
    Rails.logger.info('Disconnected from ActiveRecord')
  end

  # Before forking, kill the master process that belongs to the .oldbin PID.
  # This enables 0 downtime deploys.
  old_pid = File.join RAILS_ROOT, "tmp/pids/unicorn.pid.oldbin"
  if File.exists?(old_pid) && server.pid != old_pid
    begin
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
    Rails.logger.info('Connected to ActiveRecord')
  end
  child_pid = server.config[:pid].sub(".pid", ".#{worker.nr}.pid")
  system("echo #{Process.pid} > #{child_pid}")
end
