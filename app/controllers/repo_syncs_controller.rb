class RepoSyncsController < ApplicationController
  respond_to :json

  def create
    JobQueue.push(
      RepoSynchronizationJob,
      current_user.id,
      Rails.application.secrets['gitlab_private_token']
    )
    head 201
  end
end
