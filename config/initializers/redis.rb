Sidekiq.configure_server do |config|
  config.redis = { url: Rails.application.secrets.redis_url, namespace: 'gitlab-hound' }
end

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.application.secrets.redis_url, namespace: 'gitlab-hound' }
end
