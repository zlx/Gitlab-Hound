class ActivationsController < ApplicationController
  class FailedToActivate < StandardError; end
  class CannotActivatePrivateRepo < StandardError; end

  respond_to :json

  def create
    if activator.activate(repo, Rails.application.secrets['gitlab_private_token'])
      #analytics.track_activated(repo)
      render json: repo, status: :created
    else
      report_exception(
        FailedToActivate.new('Failed to activate repo'),
        user_id: current_user.id,
        repo_id: params[:repo_id]
      )
      head 502
    end
  end

  private

  def repo
    @repo ||= current_user.repos.find(params[:repo_id])
  end

  def activator
    RepoActivator.new
  end
end
