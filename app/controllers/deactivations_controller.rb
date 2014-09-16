class DeactivationsController < ApplicationController
  class FailedToActivate < StandardError; end

  respond_to :json

  def create
    repo = current_user.repos.find(params[:repo_id])

    if activator.deactivate(repo, Rails.application.secrets['gitlab_private_token'])
      analytics.track_deactivated(repo)
      render json: repo, status: :created
    else
      report_exception(
        FailedToActivate.new('Failed to deactivate repo'),
        user_id: current_user.id, repo_id: params[:repo_id]
      )
      head 502
    end
  end

  private

  def activator
    RepoActivator.new
  end
end
