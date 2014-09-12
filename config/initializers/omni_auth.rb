Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :github,
    Rails.application.secrets['GITHUB_CLIENT_ID'],
    Rails.application.secrets['GITHUB_CLIENT_SECRET'],
    scope: 'user:email,repo'
  )
end
