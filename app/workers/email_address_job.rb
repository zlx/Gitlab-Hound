class EmailAddressJob
  include Sidekiq::Worker

  sidekiq_options queue: :high, retry: 10

  def perform(user_id, github_token)
    user = User.find(user_id)
    github = GithubApi.new(github_token)
    email_address = github.email_address
    if user.reload.email_address.blank?
      user.update(email_address: email_address.downcase)
    end
  end
end
