require 'spec_helper'

describe GitlabPushPayload do
  let(:auth_token) { 'authtoken' }
  let(:api) { GitlabApi.new }
  let(:payload_data) do
    {"before"=>"1ed59b11560d68900409af1c1ce47b13fb8614fb", "after"=>"0ae77252d6b190e62708bbda6e7c546e3451cb45", "ref"=>"refs/heads/feature", "user_id"=>2, "user_name"=>"Jim", "project_id"=>3}
  end

  subject { GitlabPushPayload.new(payload_data, api) }

  it "should return project id" do
    expect(subject.project_id).to eq 3
  end

  it "should return branch name" do
    expect(subject.branch_name).to eq 'feature'
  end

  context "to_gitlab_payload" do
    it "should return GitlabPayload" do
      stub_get('http://gitlab.smartlionapp.com/api/v3/projects/3/merge_requests?state=opened',
               'merge_requests')
      expect(subject.to_gitlab_payload).to be_kind_of GitlabPayload
    end

    it "should return nil" do
      stub_get('http://gitlab.smartlionapp.com/api/v3/projects/3/merge_requests?state=opened',
               'empty_team_users')
      expect(subject.to_gitlab_payload).to be_nil
    end
  end

end
