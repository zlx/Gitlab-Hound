module HttpsHelper
  def with_https_enabled
    Rails.application.secrets['ENABLE_HTTPS'] = true
    yield
    Rails.application.secrets['ENABLE_HTTPS'] = false
  end
end
