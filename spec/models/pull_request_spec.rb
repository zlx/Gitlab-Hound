require "spec_helper"

describe PullRequest do
  describe "#opened?" do
    context "when payload action is opened" do
      it "returns true" do
        payload = double(:payload, action: "opened")
        pull_request = PullRequest.new(payload, "token")

        expect(pull_request).to be_opened
      end
    end

    context "when payload action is not opened" do
      it "returns false" do
        payload = double(:payload, action: "notopened")
        pull_request = PullRequest.new(payload, "token")

        expect(pull_request).not_to be_opened
      end
    end
  end

  describe "#comments" do
    it "returns comments on pull request" do
      payload = double(
        :payload,
        full_repo_name: "org/repo",
        number: 4,
        head_sha: "abc123"
      )
      patch_position = 7
      filename = "spec/models/style_guide_spec.rb"
      comment = double(:comment, position: patch_position, path: filename)
      github = double(:github, pull_request_comments: [comment])
      allow(GitlabApi).to receive(:new).and_return(github)
      pull_request = PullRequest.new(payload, "githubtoken")

      comments = pull_request.comments

      expect(comments.size).to eq(1)
      expect(comments).to match_array([comment])
    end
  end

  describe "#add_comment" do
    it "posts a comment to GitHub for the Hound user" do
      payload = double(
        :payload,
        full_repo_name: "org/repo",
        number: "123",
        head_sha: "1234abcd"
      )
      commit = double(:commit, repo_name: payload.full_repo_name)
      github = double(:github_client, add_comment: nil)
      allow(GitlabApi).to receive(:new).and_return(github)
      allow(Commit).to receive(:new).and_return(commit)
      violation = double(
        :violation,
        messages: ["A comment"],
        filename: "test.rb",
        line_number: 123
      )

      pull_request = PullRequest.new(payload, "gh-token")

      pull_request.add_comment(violation)

      expect(github).to have_received(:add_comment).with(
        pull_request_number: payload.number,
        commit: commit,
        comment: "A comment",
        filename: "test.rb",
        patch_position: 123
      )
    end
  end

  describe "#config" do
    context "when config file is present" do
      it "returns the contents of custom config" do
        api = double(:github_api, file_contents: "test", branch_commit: 'assddfre322wwe')
        pull_request = pull_request(api)

        config = pull_request.file_content("path/file.extension")

        expect(config).to eq("test")
      end
    end

    context "when config file is not present" do
      it "returns blank" do
        api = double(:github_api, branch_commit: 'assddfre322wwe')
        pull_request = pull_request(api)
        allow(api).to receive(:file_contents).and_raise(Gitlab::Error::Error)

        config = pull_request.file_content("path/file.extension")

        expect(config).to eq ""
      end
    end
  end

  def pull_request(api)
    payload = double(
      :payload,
      number: 1,
      full_repo_name: "org/repo",
      source_repo_id: 1,
      branch_name: 'feature',
      head_sha: "abc123"
    )
    allow(GitlabApi).to receive(:new).and_return(api)
    PullRequest.new(payload, "gh-token")
  end
end
