ENV['RAILS_ENV'] ||= 'test'

require 'fast_spec_helper'
require 'config/environment'
require 'rspec/rails'
require 'sidekiq/testing'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|

  config.before do
    DatabaseCleaner.clean
  end

  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.include Features, type: :feature
  config.include FactoryGirl::Syntax::Methods
  DatabaseCleaner.strategy = :deletion

  config.before(:each) do | example |
    # Clears out the jobs for tests using the fake testing
    Sidekiq::Worker.clear_all

    if example.metadata[:sidekiq] == :fake
      Sidekiq::Testing.fake!
    elsif example.metadata[:sidekiq] == :inline
      Sidekiq::Testing.inline!
    elsif example.metadata[:type] == :acceptance
      Sidekiq::Testing.inline!
    else
      Sidekiq::Testing.fake!
    end
  end
end

Capybara.configure do |config|
  config.javascript_driver = :webkit
  config.default_wait_time = 4
end
