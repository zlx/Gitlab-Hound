require "spec_helper"

describe EmailAddressJob do
  let(:github_token) { "authtoken" }

  context "when user email address is saved" do
    it "does not update email address" do
      user = create(:user, email_address: "jimtom@example.com")
      stub_get(
        "http://gitlab.smartlionapp.com/api/v3/user",
        "gitlab_user"
      )

      EmailAddressJob.new.perform(user.id, github_token)

      expect(user.reload.email_address).to eq "jimtom@example.com"
    end
  end

  context "when user email address is not saved" do
    it "updates email address" do
      user = create(:user, email_address: nil)
      stub_get(
        "http://gitlab.smartlionapp.com/api/v3/user",
        "gitlab_user"
      )

      EmailAddressJob.new.perform(user.id, github_token)

      expect(user.reload.email_address).to eq "primary@example.com"
    end

    it "downcases the email address" do
      user = create(:user)
      stub_get(
        "http://gitlab.smartlionapp.com/api/v3/user",
        "gitlab_user"
      )

      EmailAddressJob.new.perform(user.id, github_token)

      expect(user.reload.email_address).to eq "primary@example.com"
    end
  end
end
