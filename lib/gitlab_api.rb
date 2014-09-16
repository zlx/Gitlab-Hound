require 'gitlab'
require 'base64'

class GitlabApi
  SERVICES_TEAM_NAME = 'Services'

  pattr_initialize :token

  def client
    @client ||= Gitlab.client(endpoint: 'http://gitlab.smartlionapp.com/api/v3', private_token: token)
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

  def add_comment(options)
    # should use comment on line
    p options
    client.create_merge_request_comment()
    binding.pry
    #client.create_pull_request_comment(
      #options[:commit].repo_name,
      #options[:pull_request_number],
      #options[:comment],
      #options[:commit].sha,
      #options[:filename],
      #options[:patch_position]
    #)
  end

  def create_hook(repo_id, callback_endpoint)
    hook = client.add_project_hook(
      repo_id, 
      callback_endpoint, 
      { merge_requests_events: true }
    )

    yield hook if block_given?
  rescue Exception => error
    unless error.message.include? 'Hook already exists'
      raise
    end
  end

  def remove_hook(repo_id, hook_id)
    client.delete_project_hook(repo_id, hook_id) rescue false
  end

  def commit_files(full_repo_name, commit_sha)
    #commit = client.commit(full_repo_name, commit_sha)
    #commit.files
  end

  def pull_request_comments(full_repo_name, pull_request_number)
    #client.pull_request_comments(full_repo_name, pull_request_number)
  end

  def pull_request_files(full_repo_name, number)
    #client.pull_request_files(full_repo_name, number)
  end

  def file_contents(full_repo_name, filename, sha)
    #client.contents(full_repo_name, path: filename, ref: sha)
  end

  def user_teams
    #client.user_teams
  end

  def email_address
    #primary_email = client.emails.detect { |email| email['primary'] }
    #primary_email['email']
  end

  private

  def add_user_to_org(username, repo)
    repo_teams = client.repository_teams(repo.full_name)
    admin_team = admin_access_team(repo_teams)

    if admin_team
      add_user_to_team(username, admin_team.id)
    else
      add_user_and_repo_to_services_team(username, repo)
    end
  end

  def admin_access_team(repo_teams)
    token_bearer = GithubUser.new(self)

    repo_teams.detect do |repo_team|
      token_bearer.has_admin_access_through_team?(repo_team.id)
    end
  end

  def add_user_and_repo_to_services_team(username, repo)
    team = find_team(SERVICES_TEAM_NAME, repo)

    if team
      client.add_team_repository(team.id, repo.full_name)
    else
      team = create_team(SERVICES_TEAM_NAME, repo)
    end

    add_user_to_team(username, team.id)
  end

  def add_user_to_team(username, team_id)
    client.add_team_member(team_id, username)
  end

  def find_team(name, repo)
    client.org_teams(repo.organization.login).detect do |team|
      team.name == name
    end
  end

  def create_team(name, repo)
    client.create_team(
      repo.organization.login,
      {
        name: name,
        repo_names: [repo.full_name],
        permission: 'pull'
      }
    )
  end

  def orgs
    client.orgs
  end

  def authorized_repos(repos)
    repos.select {|repo| repo.permissions.admin }
  end
end
