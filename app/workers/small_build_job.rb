class SmallBuildJob
  include Sidekiq::Worker
  include Buildable

  sidekiq_options queue: :medium, retry: 10
end
