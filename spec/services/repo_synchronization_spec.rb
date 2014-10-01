require 'spec_helper'

describe RepoSynchronization do
  describe '#start' do
    it 'saves privacy flag' do
      attributes = {
        path_with_namespace: 'user/newrepo',
        id: 456,
        public: false,
        owner: {
          type: 'User'
        }
      }
      resource = double(:resource, to_hash: attributes.stringify_keys)
      api = double(:gitlab_api, repos: [resource])
      allow(GitlabApi).to receive(:new).and_return(api)
      user = create(:user)
      gitlab_token = 'token'
      synchronization = RepoSynchronization.new(user)

      synchronization.start

      expect(user.repos.first).to be_private
    end

    it 'saves organization flag' do
      attributes = {
        path_with_namespace: 'user/newrepo',
        id: 456,
        public: false
      }
      resource = double(:resource, to_hash: attributes.stringify_keys)
      api = double(:gitlab_api, repos: [resource])
      allow(GitlabApi).to receive(:new).and_return(api)
      user = create(:user)
      gitlab_token = 'token'
      synchronization = RepoSynchronization.new(user)

      synchronization.start

      expect(user.repos.first).to be_in_organization
    end

    it 'replaces existing repos' do
      attributes = {
        path_with_namespace: 'user/newrepo',
        id: 456,
        public: false,
        owner: {
          type: 'User'
        }
      }
      resource = double(:resource, to_hash: attributes.stringify_keys)
      gitlab_token = 'token'
      membership = create(:membership)
      user = membership.user
      api = double(:gitlab_api, repos: [resource])
      allow(GitlabApi).to receive(:new).and_return(api)
      synchronization = RepoSynchronization.new(user)

      synchronization.start

      expect(GitlabApi).to have_received(:new)
      expect(user.repos.size).to eq(1)
      expect(user.repos.first.full_github_name).to eq 'user/newrepo'
      expect(user.repos.first.github_id).to eq 456
    end

    it 'renames an existing repo if updated on gitlab' do
      membership = create(:membership)
      repo_name = 'user/newrepo'
      attributes = {
        path_with_namespace: repo_name,
        id: membership.repo.github_id,
        public: true,
        owner: {
          type: 'User'
        }
      }
      resource = double(:resource, to_hash: attributes.stringify_keys)
      gitlab_token = 'gitlabtoken'

      api = double(:gitlab_api, repos: [resource])
      allow(GitlabApi).to receive(:new).and_return(api)
      synchronization = RepoSynchronization.new(membership.user)

      synchronization.start

      expect(membership.user.repos.first.full_github_name).to eq repo_name
      expect(membership.user.repos.first.github_id).
        to eq membership.repo.github_id
    end

    describe 'when a repo membership already exists' do
      it 'creates another membership' do
        first_membership = create(:membership)
        repo = first_membership.repo
        attributes = {
          path_with_namespace: repo.full_github_name,
          id: repo.github_id,
          public: true,
          owner: {
            type: 'User'
          }
        }
        resource = double(:resource, to_hash: attributes.stringify_keys)
        gitlab_token = 'gitlabtoken'
        second_user = create(:user)
        api = double(:gitlab_api, repos: [resource])
        allow(GitlabApi).to receive(:new).and_return(api)
        synchronization = RepoSynchronization.new(second_user)

        synchronization.start

        expect(second_user.reload.repos.size).to eq(1)
      end
    end
  end
end
