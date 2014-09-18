class RepoInformationJob
  include Sidekiq::Worker

  sidekiq_options queue: :low, retry: 10

  def perform(repo_id, github_token)
    repo = Repo.find(repo_id)
    repo.touch

    github = GithubApi.new(github_token)
    github_data = github.repo(repo.full_github_name)

    repo.update_attributes!(
      private: github_data[:private],
      in_organization: github_data[:organization].present?
    )
  end
end
