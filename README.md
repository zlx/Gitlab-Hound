Gitlab-Hound
=====

Gitlab-Hound reviews Gitlab Merge Request for style guide violations.

Usage
--------

1. `cp config/secrets.yml.example config/secrets.yml` and change
3. `cp config/database.yml.example config/database.yml` and change
4. `bundle install & bundle exec rake db:setup`
5. `bin/rails s`
6. `bundle exec sidekiq -C config/sidekiq.yml`

Custom Style
-----------

### Ruby

Default: https://github.com/bbatsov/rubocop/blob/master/config/enabled.yml
Config in .hound.yml of root of your project

Contributing
------------

First, thank you for contributing!

Here a few guidelines to follow:

1. Write tests
2. Make sure the entire test suite passes locally
3. Open a pull request on GitHub
