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

Read http://blog.zlxstar.me/blog/2014/10/02/gitlabhound-di-yi-ban-shang-xian-le/ for more detail 

Custom Style
-----------

### Ruby

Default: https://github.com/zlx/Gitlab-Hound/blob/master/config/style_guides/ruby.yml

Custom Config: Config in .hound.yml of root of your project

All cops Supported: https://github.com/bbatsov/rubocop/blob/master/config/enabled.yml


Contributing
------------

First, thank you for contributing!

Here a few guidelines to follow:

1. Write tests
2. Make sure the entire test suite passes locally
3. Open a pull request on GitHub
