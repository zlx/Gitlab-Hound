require "fast_spec_helper"
require "attr_extras"
require "gitlab"
require "app/models/commit"

describe Commit do
  describe "#file_content" do
    context "when content is returned from GitHub" do
      it "returns content" do
        github = double(:github_api, file_contents: "some content", branch_commit: "e23sdswer4322saaa")
        payload = double("payload", source_repo_id: 100, branch_name: 'feature')
        commit = Commit.new("test/test", payload, github)

        expect(commit.file_content("test.rb")).to eq "some content"
      end
    end

    context "when nothing is returned from GitHub" do
      it "returns blank string" do
        github = double(:github_api, file_contents: nil, branch_commit: "e23sdswer4322saaa")
        payload = double("payload", source_repo_id: 100, branch_name: 'feature')
        commit = Commit.new("test/test", payload, github)

        expect(commit.file_content("test.rb")).to eq ""
      end
    end

    context "when content is nil" do
      it "returns blank string" do
        github = double(:github_api, file_contents: nil, branch_commit: "e23sdswer4322saaa")
        payload = double("payload", source_repo_id: 100, branch_name: 'feature')
        commit = Commit.new("test/test", payload, github)

        expect(commit.file_content("test.rb")).to eq ""
      end
    end

    context "when error occurs when fetching from GitHub" do
      it "returns blank string" do
        github = double(:github_api, branch_commit: "e23sdswer4322saaa")
        payload = double("payload", source_repo_id: 100, branch_name: 'feature')
        commit = Commit.new("test/test", payload, github)
        allow(github).to receive(:file_contents).and_raise(Gitlab::Error::Error)

        expect(commit.file_content("test.rb")).to eq ""
      end
    end
  end
end
