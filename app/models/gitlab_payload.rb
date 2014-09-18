require 'json'

class GitlabPayload
  pattr_initialize :unparsed_data

  def data
    @data ||= parse_data
  end

  def branch_name
    object_attributes['source_branch']
  end

  def source_repo_id
    object_attributes['source_project_id']
  end

  def github_repo_id
    data['project_id'] || object_attributes['target_project_id']
  end

  def full_repo_name
    Repo.find_by(github_id: github_repo_id).try(:full_github_name)
  end

  def number
    object_attributes['id']
  end

  def action
    object_attributes['state']
  end

  def commit_count
    pull_request["total_commits_count"] || 0
  end

  private

  def parse_data
    if unparsed_data.is_a? String
      JSON.parse(unparsed_data)
    else
      unparsed_data
    end
  end

  def object_attributes
    data.fetch("object_attributes", {})
  end
end
