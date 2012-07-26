source 'http://rubygems.org'

gem 'rails', '3.0.15'

gem 'rake'
gem 'capistrano' 
gem 'newrelic_rpm'
gem 'pg'
gem 'clearance', '=0.13.0'
gem 'ruby-openid', :git => 'https://github.com/kf8a/ruby-openid.git'
gem 'rack-openid'
gem 'acts-as-taggable-on'
gem 'paperclip' 
gem 'aws-s3'
gem 'nokogiri'
gem 'RedCloth'
gem 'thinking-sphinx'
gem 'liquid'
gem 'formtastic'
# can we go back to the collective idea branch of awesome_nested_set
gem 'awesome_nested_set' #, :git => 'git://github.com/galetahub/awesome_nested_set.git'

#gem 'acts_as_textcaptcha'

gem 'unicorn'

gem 'jquery-rails' #, '>= 1.0.12'

gem 'workflow'

gem 'friendly_id'

gem 'parslet'

# for spreadsheet downloads
#gem 'spreadsheet'

# for creating bibtex formatted citations
gem 'bibtex-ruby'

gem 'metric_fu'

gem 'jammit'

# versioning support for protocols
gem 'vestal_versions', :git => 'git://github.com/adamcooper/vestal_versions'

# offile manifest
gem 'rack-offline'

gem 'dalli'

#gem 'central_logger'

gem "sitemap_generator", "~> 3.1.1"

#for coffeescript
gem 'therubyracer', :require => false
gem 'barista'

gem 'has_scope'

gem 'ris_parser', :git => 'git://github.com/kf8a/ris_parser.git'

gem 'exception_notification'

group :development, :test  do
  # bundler requires these gems in development
  # gem "rails-footnotes"
  gem 'sqlite3-ruby'
  gem 'silent-postgres'
  gem "shoulda"
  gem 'rspec-rails'
  gem "rspec"
  gem "annotate"
  gem 'spork'
end

group :test do
  gem 'mocha'
  gem 'simplecov'
  gem 'simplecov-html'

  gem "shoulda-matchers" # to use rspec like syntax
  gem 'factory_girl_rails', :require => false
  gem 'remarkable_activerecord', '>=4.0.0.alpha2'

  #Cucumber stuff
  gem 'capybara', '0.4.1.2'
  gem 'cucumber-rails' , :require => false
  gem 'spork'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'pickle'
end
