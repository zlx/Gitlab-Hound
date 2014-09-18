require "spec_helper"

describe ActivationsController, "#create" do
  context "when activation succeeds" do
    it "returns successful response" do
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, activate: true)
      allow(RepoActivator).to receive(:new).and_return(activator)
      stub_sign_in(membership.user)

      post :create, repo_id: repo.id, format: :json

      expect(response.code).to eq "201"
      expect(response.body).to eq RepoSerializer.new(repo).to_json
      expect(activator).to have_received(:activate).
        with(repo, Rails.application.secrets['gitlab_private_token'])
      expect(analytics).to have_tracked("Activated Public Repo").
        for_user(membership.user).
        with(properties: { name: repo.full_github_name })
    end
  end

  context "when activation fails" do
    it "returns error response" do
      membership = create(:membership)
      repo = membership.repo
      activator = double(:repo_activator, activate: false).as_null_object
      allow(RepoActivator).to receive(:new).and_return(activator)
      stub_sign_in(membership.user)

      post :create, repo_id: repo.id, format: :json

      expect(response.code).to eq "502"
      expect(activator).to have_received(:activate).
        with(repo, Rails.application.secrets['gitlab_private_token'])
    end
  end
end
