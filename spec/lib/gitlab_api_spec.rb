require 'fast_spec_helper'
require 'attr_extras'
require 'lib/gitlab_api'
require 'app/models/commit_diff'
require 'app/models/comment'
require 'json'

describe GitlabApi do
  let(:auth_token) { 'authtoken' }
  let(:api) { GitlabApi.new }
  let(:repo_id) { 10 }
  let(:repo_name) { 'namespace/name' }

  describe '#repos' do
    it 'fetches all repos from Github' do
      stub_get('http://gitlab.smartlionapp.com/api/v3/projects', 'projects')
      repos = api.repos
      expect(repos.size).to eq 2
    end
  end

  describe '#add_user_to_repo' do
    it 'should check user in project team members' do
      repo_id = 10
      stub_get('http://gitlab.smartlionapp.com/api/v3/projects/10', 'project')
      stub_get(
        'http://gitlab.smartlionapp.com/api/v3/projects/10/members?query=zlx', 
        'team_users'
      )
      expect(api.add_user_to_repo('zlx', repo_id)).to eq true
    end

    it 'should raise when user not in project team members' do
      repo_id = 10
      stub_get('http://gitlab.smartlionapp.com/api/v3/projects/10', 'project')
      stub_get(
        'http://gitlab.smartlionapp.com/api/v3/projects/10/members?query=zlx',
        'empty_team_users'
      )
      expect { 
        api.add_user_to_repo('zlx', repo_id) 
      }.to raise_error(RuntimeError)
    end
  end

  describe '#create_hook' do
    it 'should create merge request & push events hook' do
      callback_url = 'http://example.com/callback_url'
      stub_post('http://gitlab.smartlionapp.com/api/v3/projects/10/hooks', 
                'gitlab_hook')

      client = double("client", add_project_hook: true)
      allow(Gitlab).to receive(:client).and_return(client)
      expect(client).to receive(:add_project_hook).with(
        10, callback_url, {
        push_events: true,
        merge_requests_events: true
      })

      api.create_hook 10, callback_url
    end

  end

  describe '#repo' do
    it 'should get project via id' do
      stub_get('http://gitlab.smartlionapp.com/api/v3/projects/10', 'project')

      expect(api.repo(10)).to be_kind_of(Gitlab::ObjectifiedHash)
    end

    it 'should get project via namespace/name' do
      repo_name = 'namespace/name'
      stub_get(
        "http://gitlab.smartlionapp.com/api/v3/projects/#{CGI::escape(repo_name)}", 
        'project_with_name'
      )

      expect(api.repo(repo_name)).to be_kind_of(Gitlab::ObjectifiedHash)
    end
  end

  describe '#add_commit' do
    it 'should add commit to gitlab' do
      stub_get(
        "http://gitlab.smartlionapp.com/api/v3/projects/#{CGI::escape(repo_name)}", 
        'project_with_name'
      )
      stub_post(
        'http://gitlab.smartlionapp.com/api/v3/projects/7/merge_request/100/comments', 
        'comment'
      )
      commit = double('commit',
                      sha: 'randomlonglongstring',
                      repo_name: repo_name)
      api.add_comment(
        commit: commit,
        pull_request_number: 100,
        filename: 'run.rb',
        comment: 'blablabla<br/>blablabla'
      )
    end
  end

  describe '#commit_files' do
    it 'should return commit files via commit_sha' do
      stub_get(
        "http://gitlab.smartlionapp.com/api/v3/projects/#{CGI::escape(repo_name)}", 
        'project_with_name'
      )
      commit_sha = 'longlongrandomstring'
      stub_get(
        "http://gitlab.smartlionapp.com/api/v3/projects/7/repository/commits/#{commit_sha}/diff", 
        'comment_files'
      )
      file = api.commit_files(repo_name, commit_sha).last
      expect(file).to be_kind_of CommitDiff
      expect(file.filename).to eq 'run.rb'
      expect(file.patch).to eq '---file  +++file'
      expect(file.status).to eq 'removed'
    end
  end

  describe '#file_contents' do
    it 'should check if file in? commit file changed' do
      stub_get(
        "http://gitlab.smartlionapp.com/api/v3/projects/#{CGI::escape(repo_name)}", 
        'project_with_name'
      )
      stub_get(
        "http://gitlab.smartlionapp.com/api/v3/projects/7/repository/blobs/longlongrandomstring?filepath=run.rb", 'blob_sha')
      expect(api.file_contents(repo_name, 'run.rb', 'longlongrandomstring')).to eq "call run.rb\n"
    end
  end

  describe '#pull_request_comments' do
    it 'should return all comments in one merge request' do
      mr_number = 10
      stub_get(
        "http://gitlab.smartlionapp.com/api/v3/projects/#{CGI::escape(repo_name)}", 
        'project_with_name'
      )
      stub_get(
        "http://gitlab.smartlionapp.com/api/v3/projects/7/merge_request/#{mr_number}/comments?page=1&per_page=100", 
        'gitlab_comments'
      )
      comment = api.pull_request_comments(repo_name, mr_number).last
      expect(comment).to be_kind_of Comment
      expect(comment.path).to eq 'path/to/run.rb'
      expect(comment.original_position).to eq 10
    end
  end

  describe '#pull_request_files' do
    it 'should return all file changes in one merge request' do
      mr_number = 10
      stub_get(
        "http://gitlab.smartlionapp.com/api/v3/projects/#{CGI::escape(repo_name)}", 
        'project_with_name'
      )
      stub_get(
        "http://gitlab.smartlionapp.com/api/v3/projects/7/merge_request/#{mr_number}", 
        'merge_request'
      )
      stub_get(
        'http://gitlab.smartlionapp.com/api/v3/projects/7/repository/compare?from=master&to=feature', 
        'compare_merge_request_diff'
      )
      file = api.pull_request_files(repo_name, mr_number).last
      expect(file).to be_kind_of CommitDiff
    end
  end

  describe "branch_commit" do
    it "should return branch head commit" do
      stub_get(
        'http://gitlab.smartlionapp.com/api/v3/projects/7/repository/branches/feature', 
        'branch_commits'
      )
      expect(api.branch_commit(7, 'feature')).to eq "7b5c3cc8be40ee161ae89a06bba6229da1032a0c"
    end
  end

end
