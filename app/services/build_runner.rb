class BuildRunner
  vattr_initialize :payload

  def run
    if repo && relevant_pull_request?
      repo.builds.create!(violations: violations)
      commenter.comment_on_violations(violations)
    end
  end

  private

  def relevant_pull_request?
    pull_request.opened? || pull_request.reopened?
  end

  def violations
    @violations ||= style_checker.violations
  end

  def style_checker
    StyleChecker.new(pull_request)
  end

  def commenter
    Commenter.new(pull_request)
  end

  def pull_request
    @pull_request ||= PullRequest.new(payload, Rails.application.secrets.gitlab['comment_private_token'])
  end

  def repo
    @repo ||= Repo.active.where(github_id: payload.github_repo_id).first
  end

end
