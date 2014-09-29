require 'json'

# gitlab merge request hook
#{
#  "object_kind": "merge_request",
#  "object_attributes": {
#    "id": 99,
#    "target_branch": "master",
#    "source_branch": "ms-viewport",
#    "source_project_id": 14,
#    "author_id": 51,
#    "assignee_id": 6,
#    "title": "MS-Viewport",
#    "created_at": "2013-12-03T17:23:34Z",
#    "updated_at": "2013-12-03T17:23:34Z",
#    "st_commits": null,
#    "st_diffs": null,
#    "milestone_id": null,
#    "state": "opened",
#    "merge_status": "unchecked",
#    "target_project_id": 14,
#    "iid": 1,
#    "description": ""
#  }
#} 

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
