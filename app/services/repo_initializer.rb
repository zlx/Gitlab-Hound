class RepoInitializer
  def self.run
    new.run
  end

  def initialize
    @user = find_user || create_user
  end

  def run
    check!
    sync!
    active!
  end

  private
  def check!
    secrets = Rails.application.secrets
    p "########### 请确保按照 README 完成配置!!!##########"

    if secrets.gitlab['base_url'].blank? || !secrets.gitlab['base_url'].match(/\Ahttp:\/\/\S*\/api\/v3\Z/)
      fail "请确保 gitlab.base_url 配置正确"
    end

    if secrets.gitlab['main_username'].blank? || secrets.gitlab['main_username'] == 'xxx'
      fail '请确保 gitlab.main_username 配置正确'
    end

    if secrets.gitlab['main_private_token'].blank? || secrets.gitlab['main_private_token'] == 'xxx'
      fail '请确保 gitlab.main_private_token 配置正确'
    end

    if secrets.gitlab['comment_username'].blank? || secrets.gitlab['comment_username'] == 'xxx'
      fail '请确保 gitlab.comment_username 配置正确'
    end

    if secrets.gitlab['comment_private_token'].blank? || secrets.gitlab['comment_private_token'] == 'xxx'
      fail '请确保 gitlab.comment_private_token 配置正确'
    end

    if secrets['redis_url'].blank?
      fail '请确保 redis_url 配置正确'
    end

    if secrets['hook_base_url'].blank?
      fail '请确保 hook_base_url 配置正确'
    end

  end

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
