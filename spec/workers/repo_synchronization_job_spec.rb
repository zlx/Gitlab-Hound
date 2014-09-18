require 'spec_helper'

describe RepoSynchronizationJob do

  describe '.perform' do
    it 'syncs repos and sets refreshing_repos to false' do
      user = create(:user)
      github_token = 'token'
      synchronization = double(:repo_synchronization, start: nil)
      allow(RepoSynchronization).to receive(:new).and_return(synchronization)

      RepoSynchronizationJob.new.perform(user.id, github_token)

      expect(RepoSynchronization).to have_received(:new).with(
        user,
        github_token
      )
      expect(synchronization).to have_received(:start)
      expect(user.reload).not_to be_refreshing_repos
    end

  end
end
