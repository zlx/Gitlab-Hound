class RepoSynchronizationJob
  include Sidekiq::Worker

  sidekiq_options queue: :high, retry: 10

  def perform(user_id, github_token)
    user = User.find(user_id)
    user.update_attribute(:refreshing_repos, true)

    synchronization = RepoSynchronization.new(user)
    synchronization.start

    user.update_attribute(:refreshing_repos, false)
  end
end
