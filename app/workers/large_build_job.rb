class LargeBuildJob
  include Sidekiq::Worker
  include Buildable

  sidekiq_options queue: :low, retry: 10
end
