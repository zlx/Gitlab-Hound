class BuildsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    if merge_request_hook?
      JobQueue.push(SmallBuildJob, payload.data)
    else
      JobQueue.push(PushEventsJob, push_payload.data)
    end
    head :ok
  end

  private

  def merge_request_hook?
    params[:object_kind] == 'merge_request'
  end

  def payload
    @payload ||= GitlabPayload.new(params.except(:controller, :action) || request.raw_post)
  end

  def push_payload
    @push_payload ||= GitlabPushPayload.new(params.except(:controller, :action) || request.raw_post)
  end

end
