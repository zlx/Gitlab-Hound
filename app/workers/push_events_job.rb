class PushEventsJob
  include Sidekiq::Worker

  sidekiq_options queue: :low, retry: 3

  def perform(payload)
    payload = GitlabPushPayload.new(payload, gitlab).to_gitlab_payload
    JobQueue.push(SmallBuildJob, payload.data) if payload
  end

  private
  def gitlab
    GitlabApi.new(Rails.application.secrets.gitlab_ptivate_token)
  end

end
