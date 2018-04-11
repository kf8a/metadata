# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~>5.2'

gem 'activerecord-session_store'
gem 'responders'

gem 'acts-as-taggable-on'
gem 'capistrano', '~>2'
gem 'clearance'
# gem 'country_select'
gem 'formtastic'
gem 'nokogiri'
gem 'paperclip', '~> 5.2'
gem 'pg'
gem 'rake', '< 11.0'
gem 'RedCloth'

# gem 'doi', :git => 'git://github.com/kf8a/doi.git'

gem 'awesome_nested_set'

gem 'jquery-rails'

# gem 'net-ssh'

gem 'workflow'

gem 'parslet'

# for creating bibtex formatted citations
gem 'bibtex-ruby'

# versioning support for protocols
gem 'vestal_versions', git: 'https://github.com/RoleModel/vestal_versions.git' # 'https://github.com/R1V3R5/vestal_versions'

gem 'dalli'

gem 'has_scope', '<0.6'

gem 'ris_parser', git: 'https://github.com/kf8a/ris_parser.git'

gem 'mysql2'
gem 'thinking-sphinx'

gem 'aws-sdk', '~> 2.3.0'

gem 'sitemap_generator'

group :production do
  gem 'exception_notification'
  gem 'unicorn'
  # gem 'newrelic_rpm'
end

# gem 'less-rails'
gem 'coffee-rails'
gem 'sass-rails'
gem 'therubyracer', require: false
gem 'uglifier'

gem 'prometheus-client' # , '~> 0.4.2'
gem 'web-console', group: :development

gem 'awesome_print'

group :development do
  gem 'bcrypt_pbkdf'
  gem 'rbnacl', '< 5.0'
  gem 'rbnacl-libsodium'
end

group :development, :test do
  gem 'byebug'
  gem 'minitest'
  gem 'minitest-reporters', '>= 0.5.0'
  gem 'spring'

  gem 'annotate'
  gem 'meta_request'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'test-unit'
end

group :test do
  gem 'factory_girl_rails'
  gem 'shoulda', git: 'https://github.com/thoughtbot/shoulda.git'
  gem 'shoulda-matchers' # to use rspec like syntax

  # Cucumber stuff
  # gem 'capybara'
  # gem 'cucumber-rails' , :require => false
  # gem 'pickle'
  # gem 'selenium-webdriver'
  gem 'database_cleaner'
end
