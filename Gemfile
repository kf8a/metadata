# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '~>7.0'

gem 'commonmarker'

gem 'activerecord-session_store'
gem 'responders'

gem 'bootsnap', require: false

gem 'acts-as-taggable-on'
gem 'devise'
gem 'formtastic'
gem 'nokogiri'

gem "sprockets-rails"

gem 'pg'
gem 'country_select', '~> 9.0'

# gem 'doi', :git => 'git://github.com/kf8a/doi.git'

gem 'awesome_nested_set'

gem 'jquery-rails'
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

gem 'workflow'
gem 'workflow-activerecord'

gem 'parslet'

# for creating bibtex formatted citations
gem 'bibtex-ruby'

gem 'dalli'

gem 'has_scope' # , '<0.6'

gem 'ris_parser', git: 'https://github.com/kf8a/ris_parser.git'

gem 'mysql2'
gem 'thinking-sphinx'

gem 'aws-sdk-s3', '~> 1'

gem 'rake', '>= 12.3.3'

gem 'sitemap_generator'

gem 'puma'
gem 'rexml'

group :production, :staging do
  gem 'exception_notification'
end

gem 'sass-rails', '>= 5'
# gem 'therubyracer', require: false
# gem 'uglifier'

gem 'prometheus-client'
# gem 'web-console', group: :development

gem 'faraday'
gem 'faraday-follow_redirects'

# gem 'omniauth'
gem 'omniauth-glbrc', git: "git@github.com:kf8a/omniauth-glbrc.git"
# try to update to omniauth 2.0
# gem 'omniauth-glbrc', path: "../omniauth-glbrc"
gem 'omniauth-rails_csrf_protection'


group :development do
  gem 'awesome_print'
  gem 'bcrypt_pbkdf'
  gem 'capistrano', require: false
  gem 'capistrano3-puma', github: "seuros/capistrano-puma"
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails'
  gem 'capistrano-asdf'
  gem 'ed25519'

  gem 'listen'
  # gem 'railroady'
  gem 'rails-erd'
  gem 'rbnacl'
  gem 'rbnacl-libsodium'
  gem 'rubocop', require: false
  gem 'rubocop-rails'
  gem 'rubocop-thread_safety'
end

group :development, :test do
  gem 'minitest'
  # gem 'minitest-reporters', '>= 0.5.0'

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

# gem "tailwindcss-rails"
