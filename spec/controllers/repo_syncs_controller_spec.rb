require 'spec_helper'

describe RepoSyncsController, '#create' do
  it 'enqueues repo sync job' do
    user = create(:user)
    stub_sign_in(user)
    allow(JobQueue).to receive(:push)

    post :create

    expect(JobQueue).to have_received(:push).
      with(RepoSynchronizationJob, user.id, Rails.application.secrets['gitlab_private_token'])
  end
end
