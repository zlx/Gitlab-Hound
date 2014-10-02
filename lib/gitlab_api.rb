require 'gitlab'
require 'base64'

class GitlabApi
  SERVICES_TEAM_NAME = 'Services'
  def initialize token=nil
    @token = token || default_token
  end

  def client
    @client ||= Gitlab.client(endpoint: 'http://gitlab.smartlionapp.com/api/v3', private_token: @token)
  end

  def repos
    client.projects
  end

  def add_user_to_repo(username, repo_id)
    repo = repo(repo_id)
    if client.team_members(repo_id, query: username).empty?
      fail "Please add #{username} into #{repo.name} team members"
    end
    true
  end

  def repo(repo_id)
    if repo_id.is_a? Integer
      client.project(repo_id)
    else
      client.project(CGI::escape(repo_id))
    end
  end

  def branch_commit(repo_id, branch_name)
    client.branch(repo_id, branch_name).commit.id
  end

  def add_comment(options)
    repo = repo(options[:commit].repo_name)
    client.create_merge_request_comment(repo.id, options[:pull_request_number], options[:comment], {
      file_path: options[:filename],
      line: options[:patch_position],
      line_type: 'new'
    })
  end

  def create_hook(repo_id, callback_endpoint)
    hook = client.add_project_hook(
      repo_id, 
      callback_endpoint, 
      { push_events: true, merge_requests_events: true }
    )

    yield hook if block_given?
  rescue Gitlab::Error::Error
    Rails.logger.tagged do
      Rails.logger.error "Create Hook for #{repo_id} with #{callback_endpoint} fail"
    end
  rescue Exception
    raise
  end

  def remove_hook(repo_id, hook_id)
    client.delete_project_hook(repo_id, hook_id) rescue false
  end

  def commit_files(full_repo_name, commit_sha)
    repo = repo(full_repo_name)
    client.commit_diff(repo.id, commit_sha)
    .map{ |diff| build_commit_diff(diff) }
  end

  def opened_merge_requests(repo_id)
    client.merge_requests(repo_id, state: 'opened')
  end

  def pull_request_comments(full_repo_name, pull_request_number)
    repo = repo(full_repo_name)
    comments, page = [], 1
    loop do
      cs = client.merge_request_comments(repo.id, pull_request_number, per_page: 100, page: page)
      comments += cs
      page += 1
      break if cs.count < 100
    end
    comments.map { |comment| Comment.new(comment.file_path, comment.line, comment.note) }
  end

  def pull_request_files(full_repo_name, number)
    repo = repo(full_repo_name)
    mr = client.merge_request(repo.id, number)
    client.compare(repo.id, mr.target_branch, mr.source_branch)
    .diffs.map{ |diff| build_commit_diff(diff) }
  end

  def file_contents(full_repo_name, filename, sha)
    repo = repo(full_repo_name)
    client.contents(repo.id, sha, filename)
  end

  def user_teams
    #client.user_teams
  end

  def email_address
    client.user.email
  end

  private

  def build_commit_diff diff
    diff = OpenStruct.new(diff) if diff.is_a? Hash
    CommitDiff.new(diff.diff, diff.new_path, if diff.deleted_file
          "removed"
        elsif diff.new_file
          "added"
        elsif diff.renamed_file
          "rename"
        else
          "modified"
        end)
  end

  def default_token
    Rails.application.secrets.gitlab['main_private_token']
  end

end
