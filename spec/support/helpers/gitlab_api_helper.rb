module GitlabApiHelper
  def stub_repo_requests(auth_token)
    stub_request(
      :get,
      "http://gitlab.smartlionapp.com/api/v3/projects"
    ).with(
      headers: { 'Accept' => 'application/json', 'Private-Token' => "#{auth_token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/projects.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_repo_request(repo_id, auth_token)
    body = if repo_id.is_a?(Integer)
      File.read('spec/support/fixtures/project.json').gsub("ID", "#{repo_id}")
    else
      File.read('spec/support/fixtures/project_with_name.json').gsub("REPO_NAME", repo_id)
    end

    stub_request(
      :get,
      "http://gitlab.smartlionapp.com/api/v3/projects/#{repo_id.is_a?(Integer) ? repo_id : CGI::escape(repo_id)}"
    ).with(
      headers: { 'Accept' => 'application/json', 'Private-Token' => "#{auth_token}" }
    ).to_return(
      status: 200,
      body: body,
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_repo_teams_query_request(repo_id, query, token = auth_token)
    stub_request(
      :get,
      "http://gitlab.smartlionapp.com/api/v3/projects/#{repo_id}/members?query=#{query}"
    ).with(
      headers: { 'Accept' => 'application/json', 'Private-Token' => "#{token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/team_users.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_repo_teams_query_empty_request(repo_id, query, token = auth_token)
    stub_request(
      :get,
      "http://gitlab.smartlionapp.com/api/v3/projects/#{repo_id}/members?query=#{query}"
    ).with(
      headers: { 'Accept' => 'application/json', 'Private-Token' => "#{token}" }
    ).to_return(
      status: 200,
      body: '[]',
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_add_hook_request(repo_id, callback_url, token = auth_token)
    stub_request(
      :post, 
      "http://gitlab.smartlionapp.com/api/v3/projects/#{repo_id}/hooks"
    ).with(
      headers: { 'Accept' => 'application/json', 'Private-Token' => "#{token}" },
      body: "url=#{CGI::escape(callback_url)}&merge_requests_events=true"
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/gitlab_hook.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_add_comment_request(repo_id, pull_request_number, token, options)
    stub_request(
      :post, 
      "http://gitlab.smartlionapp.com/api/v3/projects/#{repo_id}/merge_request/#{pull_request_number}/comments"
    ).with(
      headers: { 'Accept' => 'application/json', 'Private-Token' => "#{token}" },
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/comment.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  def stub_commit_files_request(repo_id, commit_sha, token)
    stub_request(
      :get, 
      "http://gitlab.smartlionapp.com/api/v3/projects/#{repo_id}/repository/commits/#{commit_sha}/diff"
    ).with(
      :headers => { 'Accept' => 'application/json', 'Private-Token' => "#{token}" }
    ).to_return(
      :status => 200, 
      :body => File.read('spec/support/fixtures/comment_files.json'), 
      :headers => {}
    )
  end

  private

  def auth_token
    AuthenticationHelper::GITHUB_TOKEN
  end
end
