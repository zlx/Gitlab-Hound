class RepoSynchronizationJob
  include Sidekiq::Worker

  sidekiq_options queue: :high, retry: 10

  def perform(user_id, github_token)
# before
    user = User.find(user_id)
    user.update_attribute(:refreshing_repos, true)

    user = User.find(user_id)
    synchronization = RepoSynchronization.new(user, github_token)
    synchronization.start
    user.update_attribute(:refreshing_repos, false)
  end
end
