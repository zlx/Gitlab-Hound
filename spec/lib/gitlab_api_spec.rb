require 'fast_spec_helper'
require "attr_extras"
require 'lib/gitlab_api'
require 'app/models/commit_diff'
require 'json'

describe GitlabApi do
  let(:auth_token) { 'authtoken' }
  let(:api) { GitlabApi.new(auth_token) }
  let(:repo_id) { 10 }
  let(:repo_name) { 'namespace/name' }

  describe '#repos' do
    it 'fetches all repos from Github' do
      stub_repo_requests(auth_token)

      repos = api.repos

      expect(repos.size).to eq 2
    end
  end

  describe "#add_user_to_repo" do
    it "should check user in project team members" do
      repo_id = 10
      stub_repo_request(repo_id, auth_token)
      stub_repo_teams_query_request(repo_id, 'zlx', auth_token)

      expect(api.add_user_to_repo("zlx", repo_id)).to eq true
    end

    it "should raise when user not in project team members" do
      repo_id = 10
      stub_repo_request(repo_id, auth_token)
      stub_repo_teams_query_empty_request(repo_id, 'zlx', auth_token)

      expect{api.add_user_to_repo("zlx", repo_id)}.to raise_error(RuntimeError)
    end
  end

  describe "#create_hook" do
    it "should create merge request hook" do
      repo_id = 10
      repo_name = "hook_merge_request"
      callback_url = "http://example.com/callback_url"
      stub_add_hook_request(repo_id, callback_url, auth_token)

      api.create_hook repo_id, callback_url
    end

  end

  describe "#repo" do
    it "should get project via id" do
      stub_repo_request 10, auth_token

      expect(api.repo(10)).to be_kind_of(Gitlab::ObjectifiedHash)
    end

    it "should get project via namespace/name" do
      repo_name = 'namespace/name'
      stub_repo_request repo_name, auth_token

      expect(api.repo(repo_name)).to be_kind_of(Gitlab::ObjectifiedHash)
    end
  end

  describe "#add_commit" do
    it "should add commit to gitlab" do
      stub_repo_request(repo_name, auth_token)
      stub_add_comment_request(7, 100, auth_token, {})
      commit = double("commit", sha: "randomlonglongstring", repo_name: repo_name)
      api.add_comment(
        commit: commit, 
        pull_request_number: 100, 
        filename: 'run.rb', 
        comment: 'blablabla<br/>blablabla'
      )
    end
  end

  describe "#commit_files" do
    it "should return commit files via commit_sha" do
      stub_repo_request(repo_name, auth_token)
      commit_sha = "longlongrandomstring"
      stub_commit_files_request(7, commit_sha, auth_token)
      file = api.commit_files(repo_name, commit_sha).last
      expect(file).to be_kind_of CommitDiff
      expect(file.filename).to eq 'run.rb'
      expect(file.patch).to eq '---file  +++file'
      expect(file.status).to eq 'removed'
    end
  end

  describe "#file_contents" do
    it "should check if file in? commit file changed" do
      api.file_contents repo_name, 'run.rb', "longlongrandomstring"
    end
  end

  describe "#pull_request_comments" do
    it "should return all comments in one merge request" do
      mr_number = 10
      api.pull_request_comments repo_name, mr_number
    end
  end

  describe "#pull_request_files" do
    it "should return all file changes in one merge request" do
      mr_number = 10
      api.pull_request_files repo_name, mr_number
    end
  end

end
