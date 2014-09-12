class RepoActivator
  def activate(repo, gitlab_token)
    change_repository_state_quietly do
      gitlab = GitlabApi.new(gitlab_token)
      add_hound_to_repo(gitlab, repo) && create_web_hook(gitlab, repo)
    end
  end

  def deactivate(repo, gitlab_token)
    change_repository_state_quietly do
      gitlab = GitlabApi.new(gitlab_token)
      gitlab.remove_hook(repo.full_gitlab_name, repo.hook_id)
      repo.deactivate
    end
  end

  private

  def change_repository_state_quietly
    yield
  rescue Exception => error
    Rails.logger.tagged("REPO_ACTIVATOR") do
      Rails.logger.error "#{error}"
    end
    false
  end

  def create_web_hook(gitlab, repo)
    gitlab.create_hook(repo.github_id, builds_url) do |hook|
      binding.pry
      repo.update_attributes(hook_id: hook.id, active: true)
    end
  end

  def add_hound_to_repo(gitlab, repo)
    gitlab.add_user_to_repo(
      Rails.application.secrets['HOUND_GITHUB_USERNAME'],
      repo.github_id
    )
  end

  def builds_url
    protocol = Rails.application.secrets['ENABLE_HTTPS'] == 'yes' ? 'https' : 'http'
    URI.join("#{protocol}://#{Rails.application.secrets['HOST']}", 'builds').to_s
  end
end
