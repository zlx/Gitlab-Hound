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

end
