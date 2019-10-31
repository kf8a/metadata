# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~>5.2'

gem 'activerecord-session_store'
gem 'responders'

gem 'bootsnap', '>= 1.1.0', require: false

gem 'acts-as-taggable-on'
gem 'devise'
gem 'formtastic'
gem 'kramdown', '~> 2.1'
gem 'nokogiri'
gem 'pg'
gem 'rake', '< 11.0'
gem 'RedCloth'

gem 'country_select', '~> 4.0'

# gem 'doi', :git => 'git://github.com/kf8a/doi.git'

gem 'awesome_nested_set'

gem 'jquery-rails'

gem 'workflow'
gem 'workflow-activerecord'

gem 'parslet'

# for creating bibtex formatted citations
gem 'bibtex-ruby'

gem 'dalli'

gem 'has_scope', '<0.6'

gem 'ris_parser', git: 'https://github.com/kf8a/ris_parser.git'

gem 'mysql2', platform: :ruby
gem 'thinking-sphinx'

gem 'aws-sdk-s3' , '~> 1'

gem 'sitemap_generator'

group :production do
  gem 'exception_notification'
  gem 'unicorn'
end

gem 'coffee-rails'
gem 'sassc-rails'
gem 'therubyracer', require: false
gem 'uglifier'

gem 'prometheus-client' # , '~> 0.4.2'
gem 'web-console', group: :development

gem 'awesome_print'

group :development do
  gem 'bcrypt_pbkdf'
  gem 'capistrano', '~>2'
  gem 'ed25519'
  gem 'listen'
  gem 'rbnacl' # , '< 5.0'
  gem 'rbnacl-libsodium'
end

group :development, :test do
  gem 'minitest'
  gem 'minitest-reporters', '>= 0.5.0'

  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'test-unit'
end

group :test do
  gem 'factory_bot_rails'
  gem 'rails-controller-testing'
  gem 'shoulda', '>= 3.0'
  gem 'shoulda-matchers' # to use rspec like syntax

  gem 'database_cleaner'
end
