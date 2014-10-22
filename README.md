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

Language Support
-------------

+ Ruby
+ JavaScript
+ CoffeeScript
+ Java


Custom Style
-----------

### Ruby

To enable Ruby style checking, add the following to .hound.yml in the root of your project

```
ruby:
  enabled: true
```

We uses [RUBOCOP](https://github.com/bbatsov/rubocop) internally so you can configure Gitlab-Hound by adding a [RUBOCOP CONFIG](https://github.com/bbatsov/rubocop/blob/master/config/enabled.yml) to your project and adding the following to .hound.yml in the root of your project.

```
ruby:
  enabled: true
  config_file: config/.rubocop.yml
```


### CoffeeScript

To enable CoffeeScript style checking, add the following to .hound.yml in the root of your project

```
coffee_script:
  enabled: true
```

We use [COFFEELINT](http://www.coffeelint.org/) internally so you can configure Gitlab-Hound by adding a [COFFEELINT CONFIG](https://github.com/clutchski/coffeelint/blob/master/coffeelint.json) to your project and adding the following to .hound.yml in the root of your project.

```
coffee_script:
  enabled: true
  config_file: config/.coffeelint.json
```

### JavaScript

To enable JavaScript style checking, add the following to .hound.yml in the root of your project

```
java_script:
  enabled: true
```

We use [JSHINT](https://github.com/jshint/jshint/) internally so you can configure Gitlab-Hound by adding a [JSHINT CONFIG](https://github.com/zlx/Gitlab-Hound/blob/master/config/style_guides/javascript.json) to your project and adding the following to .hound.yml in the root of your project.

```
java_script:
  enabled: true
  config_file: config/.jshint.json
```

### Java

To enable Java style checking, add the following to .hound.yml in the root of your project

```
java:
  enabled: true
```

We use [check styles](https://github.com/checkstyle/checkstyle) internally so you can configure Gitlab-Hound by [custom config](https://github.com/zlx/jlint/blob/master/doc/sun_checks.xml) to your project and adding the following to .hound.yml in the root of your project.

```
java:
  enabled: true
  config_file: config/.java_custom.xml
```

Default we use [sun checks](https://github.com/zlx/jlint/blob/master/doc/sun_checks.xml) for style checking, you can download google checks or sun checks from [here](https://github.com/zlx/jlint/tree/master/doc), and change them according to your team [check style checks](http://checkstyle.sourceforge.net/checks.html)

Contributing
------------

First, thank you for contributing!

Here a few guidelines to follow:

1. Write tests
2. Make sure the entire test suite passes locally
3. Open a pull request on GitHub
