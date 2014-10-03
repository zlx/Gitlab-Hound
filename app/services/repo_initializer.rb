class RepoInitializer
  def self.run
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
    Rails.application.secrets.gitlab['main_username']
  end

  def sync!
    synchronization = RepoSynchronization.new(@user)
    synchronization.start
  end

  def active!
    activator = RepoActivator.new

    active_repos activator
    deactive_repos activator
  end

  def active_repos activator
    repos = Repo.where(full_github_name: active_repos_config)
    repos.each do |repo|
      activator.activate(repo) unless repo.active?
    end
  end

  def deactive_repos activator
    repos = Repo.active.where.not(full_github_name: active_repos_config)
    repos.each do |repo|
      activator.deactivate(repo) if repo.active?
    end
  end

  def active_repos_config
    Rails.application.secrets.active_repos || []
  end
end
