Sidekiq.configure_server do |config|
  config.redis = { url: Rails.application.secrets['REDISTOGO_URL'], namespace: 'hound' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.application.secrets['REDISTOGO_URL'], namespace: 'hound' }
end
