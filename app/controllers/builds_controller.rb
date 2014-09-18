class BuildsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]
  skip_before_action :authenticate, only: [:create]

  def create
    JobQueue.push(SmallBuildJob, payload.data)
    head :ok
  end

  private

  def payload
    @payload ||= GitlabPayload.new(params || request.raw_post)
  end
end
