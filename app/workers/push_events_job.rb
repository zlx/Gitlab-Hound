class PushEventsJob
  include Sidekiq::Worker

  sidekiq_options queue: :low, retry: 3

  def perform(payload)
    gitlab_payload = GitlabPushPayload.new(payload, gitlab).to_gitlab_payload
    JobQueue.push(SmallBuildJob, gitlab_payload.data) if gitlab_payload
  end

  private
  def gitlab
    GitlabApi.new
  end

end
