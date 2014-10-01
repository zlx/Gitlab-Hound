require 'spec_helper'

describe RepoActivator do
  describe '#activate' do
    context 'when repo activation succeeds' do
      it 'activates repo' do
        gitlab_token = 'gitlabtoken'
        repo = create(:repo)
        stub_gitlab_api
        activator = RepoActivator.new

        expect(activator.activate(repo, gitlab_token)).to be_truthy
        expect(GitlabApi).to have_received(:new).with(gitlab_token)
        expect(repo.reload).to be_active
      end

      it 'makes Hound a collaborator' do
        repo = create(:repo)
        gitlab = stub_gitlab_api
        activator = RepoActivator.new

        activator.activate(repo, 'gitlabtoken')

        expect(gitlab).to have_received(:add_user_to_repo)
      end

      it 'returns true if the repo activates successfully' do
        repo = create(:repo)
        stub_gitlab_api
        activator = RepoActivator.new

        response = activator.activate(repo, 'gitlabtoken')

        expect(response).to be_truthy
      end

      it 'creates GitLab hook using insecure build URL' do
        repo = create(:repo)
        gitlab = stub_gitlab_api
        activator = RepoActivator.new

        activator.activate(repo, 'gitlabtoken')

        expect(gitlab).to have_received(:create_hook).with(
          repo.github_id,
          URI.join("#{Rails.application.secrets.hook_base_url}", 'builds').to_s
        )
      end
    end

    context 'when repo activation fails' do
      it 'returns false if API request raises' do
        gitlab_token = nil
        repo = double('repo')
        expect(GitlabApi).to receive(:new).and_raise(Gitlab::Error::Error.new)
        activator = RepoActivator.new

        response = activator.activate(repo, gitlab_token)

        expect(response).to be_falsy
      end

      context 'when Hound cannot be added to repo' do
        it 'returns false' do
          repo = double(:repo, full_gitlab_name: 'test/repo')
          gitlab = double(:gitlab, add_user_to_repo: false)
          allow(GitlabApi).to receive(:new).and_return(gitlab)
          activator = RepoActivator.new

          expect(activator.activate(repo, gitlab)).to be_falsy
        end
      end
    end

    context 'hook already exists' do
      it 'does not raise' do
        token = 'token'
        repo = create(:repo)
        gitlab = double(:gitlab, create_hook: nil, add_user_to_repo: true)
        allow(GitlabApi).to receive(:new).and_return(gitlab)
        activator = RepoActivator.new

        expect { activator.activate(repo, token) }.not_to raise_error

        expect(GitlabApi).to have_received(:new).with(token)
      end
    end
  end

  describe '#deactivate' do
    context 'when repo activation succeeds' do
      it 'deactivates repo' do
        stub_gitlab_api
        gitlab_token = 'gitlabtoken'
        repo = create(:repo)
        create(:membership, repo: repo)
        activator = RepoActivator.new

        activator.deactivate(repo, gitlab_token)

        expect(GitlabApi).to have_received(:new).with(gitlab_token)
        expect(repo.active?).to be_falsy
      end

      it 'removes GitLab hook' do
        gitlab_api = stub_gitlab_api
        repo = create(:repo)
        create(:membership, repo: repo)
        activator = RepoActivator.new

        activator.deactivate(repo, 'gitlabtoken')

        expect(gitlab_api).to have_received(:remove_hook)
        expect(repo.hook_id).to be_nil
      end

      it 'returns true if the repo activates successfully' do
        stub_gitlab_api
        membership = create(:membership)
        activator = RepoActivator.new

        response = activator.deactivate(membership.repo, "gitlabtoken")

        expect(response).to be_truthy
      end
    end

    context 'when repo activation succeeds' do
      it 'returns false if the repo does not activate successfully' do
        repo = double('repo')
        gitlab_token = nil
        expect(GitlabApi).to receive(:new).and_raise(Gitlab::Error::Error.new)
        activator = RepoActivator.new

        response = activator.deactivate(repo, gitlab_token)

        expect(response).to be_falsy
      end
    end
  end

  def stub_gitlab_api
    hook = double(:hook, id: 1)
    api = double(:gitlab_api, add_user_to_repo: true, remove_hook: true)
    allow(api).to receive(:create_hook).and_yield(hook)
    allow(GitlabApi).to receive(:new).and_return(api)
    api
  end
end
