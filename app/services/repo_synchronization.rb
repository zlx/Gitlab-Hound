class RepoSynchronization
  pattr_initialize :user
  attr_reader :user

  def api
    @api ||= GitlabApi.new
  end

  def start
    user.repos.clear

    api.repos.each do |resource|
      attributes = repo_attributes(resource.to_hash)
      user.repos << Repo.find_or_create_with(attributes)
    end
  end

  private

  def repo_attributes(attributes)
    {
      private: !attributes["public"],
      github_id: attributes["id"],
      full_github_name: attributes["path_with_namespace"],
      in_organization: attributes["owner"].nil?
    }
  end
end
