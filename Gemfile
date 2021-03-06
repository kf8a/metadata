# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~>6.0'

gem 'activerecord-session_store'
gem 'responders'

gem 'bootsnap', '>= 1.1.0', require: false

gem 'acts-as-taggable-on'
gem 'devise'
gem 'formtastic'
gem 'nokogiri'
gem 'pg'
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

gem 'has_scope' # , '<0.6'

gem 'ris_parser', git: 'https://github.com/kf8a/ris_parser.git'

gem 'mysql2', platform: :ruby
gem 'thinking-sphinx'

gem 'aws-sdk-s3', '~> 1'

gem 'rake', '>= 12.3.3'

gem 'sitemap_generator'

gem 'puma'

group :production, :staging do
  gem 'exception_notification'
  # gem 'unicorn'
end

gem 'coffee-rails'
gem 'sassc-rails'
gem 'therubyracer', require: false
gem 'uglifier'

gem 'prometheus-client'
gem 'web-console', group: :development

gem 'faraday'

# gem 'glbrc_auth_helper', path: '../glbrc_auth_helper'

group :development do
  gem 'awesome_print'
  gem 'bcrypt_pbkdf'
  gem 'capistrano', require: false
  gem 'capistrano3-puma', github: "seuros/capistrano-puma"
  # gem 'capistrano3-unicorn'
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails'
  gem 'ed25519'

  gem 'listen'
  gem 'railroady'
  gem 'rbnacl'
  gem 'rbnacl-libsodium'
  gem 'rubocop', require: false
  gem 'rubocop-rails'
  gem 'rubocop-thread_safety'
end

group :development, :test do
  gem 'minitest'
  gem 'minitest-reporters', '>= 0.5.0'

  gem 'rspec-its'
  # TODO: go back to standard gem once 4.0 has been released
  # gem 'rspec-rails', git: 'https://github.com/rspec/rspec-rails', tag: 'v4.0.0.beta4'

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
