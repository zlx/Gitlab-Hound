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
    stub_request(
      :get,
      "http://gitlab.smartlionapp.com/api/v3/projects/#{repo_id}"
    ).with(
      headers: { 'Accept' => 'application/json', 'Private-Token' => "#{auth_token}" }
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/project.json').gsub("ID", "#{repo_id}"),
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
      body: "url=http%3A%2F%2Fexample.com%2Fcallback_url"
    ).to_return(
      status: 200,
      body: File.read('spec/support/fixtures/gitlab_hook.json'),
      headers: { 'Content-Type' => 'application/json; charset=utf-8' }
    )
  end

  private

  def auth_token
    AuthenticationHelper::GITHUB_TOKEN
  end
end
