REDIS = Redis.new(url: Rails.application.secrets['REDISTOGO_URL'])
Resque.redis = REDIS
