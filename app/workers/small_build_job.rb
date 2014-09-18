class SmallBuildJob
  include Sidekiq::Worker

  sidekiq_options queue: :medium, retry: 10

  def perform(payload_data)
    payload = GitlabPayload.new(payload_data)
    build_runner = BuildRunner.new(payload)
    build_runner.run
  end
end
