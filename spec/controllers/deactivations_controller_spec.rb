require 'spec_helper'

describe DeactivationsController, '#create' do
  context 'when deactivation succeeds' do
    it 'returns successful response' do
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, deactivate: true)
      allow(RepoActivator).to receive(:new).and_return(activator)
      stub_sign_in(membership.user)

      post :create, repo_id: repo.id, format: :json

      expect(response.code).to eq '201'
      expect(response.body).to eq RepoSerializer.new(repo).to_json
      expect(activator).to have_received(:deactivate).with(
        repo,
        Rails.application.secrets['gitlab_ptivate_token']
      )
      expect(analytics).to have_tracked("Deactivated Public Repo").
        for_user(membership.user).
        with(properties: { name: repo.full_github_name })
    end
  end

  context 'when deactivation fails' do
    it 'returns error response' do
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, deactivate: false)
      allow(RepoActivator).to receive(:new).and_return(activator)
      stub_sign_in(membership.user)

      post :create, repo_id: repo.id, format: :json

      expect(response.code).to eq '502'
      expect(activator).to have_received(:deactivate).with(
        repo,
        Rails.application.secrets['gitlab_ptivate_token']
      )
    end

  end
end
