require 'fast_spec_helper'
require "attr_extras"
require 'lib/gitlab_api'
require 'json'

describe GitlabApi do

  describe '#repos' do
    it 'fetches all repos from Github' do
      auth_token = 'authtoken'
      api = GitlabApi.new(auth_token)
      stub_repo_requests(auth_token)

      repos = api.repos

      expect(repos.size).to eq 2
    end
  end

  describe "#add_user_to_repo" do
    it "should check user in project team members" do
      auth_token = 'authtoken'
      repo_id = 10
      api = GitlabApi.new(auth_token)
      stub_repo_request(repo_id, auth_token)
      stub_repo_teams_query_request(repo_id, 'zlx', auth_token)

      expect(api.add_user_to_repo("zlx", repo_id)).to eq true
    end

    it "should raise when user not in project team members" do
      auth_token = 'authtoken'
      api = GitlabApi.new(auth_token)
      repo_id = 10
      stub_repo_request(repo_id, auth_token)
      stub_repo_teams_query_empty_request(repo_id, 'zlx', auth_token)

      expect{api.add_user_to_repo("zlx", repo_id)}.to raise_error(RuntimeError)
    end
  end

  describe "#create hook" do
    it "should create merge request hook" do
      auth_token = 'authtoken'
      repo_id = 10
      repo_name = "hook_merge_request"
      callback_url = "http://example.com/callback_url"
      api = GitlabApi.new(auth_token)
      stub_add_hook_request(repo_id, callback_url, auth_token)

      api.create_hook repo_id, callback_url
    end

  end

  describe "repo" do
    it "should get project via id" do
      auth_token = 'authtoken'
      api = GitlabApi.new(auth_token)
      stub_repo_request 10, auth_token

      expect(api.repo(10)).to be_kind_of(Gitlab::ObjectifiedHash)
    end

    it "should get project via namespace/name" do
      auth_token = 'authtoken'
      api = GitlabApi.new(auth_token)
      repo_name = 'namespace/name'
      stub_repo_request repo_name, auth_token

      expect(api.repo(repo_name)).to be_kind_of(Gitlab::ObjectifiedHash)
    end
  end

end
