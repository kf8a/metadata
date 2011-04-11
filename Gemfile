source 'http://rubygems.org'

gem 'rails', '3.0.6'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'capistrano' #, :git=>'git://github.com/capistrano/capistrano.git'
gem 'newrelic_rpm'
gem 'pg'
gem 'ruby-openid', :git => 'https://github.com/kf8a/ruby-openid.git'
gem 'rack-openid'
gem 'acts-as-taggable-on'
gem 'paperclip'
gem 'aws-s3'
gem 'nokogiri'
gem 'RedCloth', '4.2.4'
gem 'thinking-sphinx'
gem 'liquid'
gem 'clearance'
gem 'formtastic'
gem 'less'
gem 'awesome_nested_set', :git => 'git://github.com/galetahub/awesome_nested_set.git'
gem 'thin'
gem 'jquery-rails', '>= 0.2.6'
gem "transitions", :require => ["transitions", "active_record/transitions"]

# for creating bibtex formatted citations
gem 'bibtex-ruby'

#Gets rid of annoying UTF-8 string error in rack
gem "escape_utils"

gem 'metric_fu'

gem 'jammit'

# versioning support for protocols
gem 'vestal_versions', :git => 'git://github.com/adamcooper/vestal_versions'

# offile manifest
gem 'rack-offline'

gem 'dalli'

group :development, :test  do
  # bundler requires these gems in development
  # gem "rails-footnotes"
  gem 'sqlite3-ruby'
  gem 'silent-postgres'
  gem "shoulda"
  gem 'rspec-rails'
  gem "rspec"
end

group :test do
  gem 'mocha'
  gem 'simplecov'
  gem 'simplecov-html'

  #gem "shoulda-matchers" # to use rspec like syntax
  gem 'factory_girl_rails'
  gem 'remarkable_activerecord', '>=4.0.0.alpha2'

  #Cucumber stuff
  gem 'capybara'
  gem "factory_girl"
  gem 'cucumber-rails'
  gem 'spork'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'pickle'
  gem 'single_test'
end
