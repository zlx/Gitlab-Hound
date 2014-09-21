class RepoInitializer
  def self.run
    p "=====Start Config Repos===="
    new.run
  end

  def initialize
    @user = find_user || create_user
  end

  def run
    sync!
    active!
  end

  private
  def find_user
    user = User.where(github_username: username).first
  end

  def create_user
    user = User.create(github_username: username)
  end

  def username
    Rails.application.secrets['gitlab_username']
  end

  def sync!
    synchronization = RepoSynchronization.new(@user, gitlab_token)
    synchronization.start
  end

  def gitlab_token
    Rails.application.secrets['gitlab_private_token']
  end

  def active!
    activator = RepoActivator.new
    repos = Repo.where(full_github_name: active_repos)
    p "=====Config #{active_repos.size} repos: #{active_repos.join('、')}===="
    repos.each do |repo|
      if repo.active? || activator.activate(repo, gitlab_token)
        p "=====Active #{repo.full_github_name} Success!===="
      end
    end
  end

  def active_repos
    Rails.application.secrets['active_repos'] || []
  end
end
