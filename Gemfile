source 'http://rubygems.org'

gem 'rails', '3.2.9'

gem 'rake'
gem 'capistrano' 
gem 'newrelic_rpm'
gem 'pg'
gem 'clearance', '1.0.0.rc4'
gem 'ruby-openid', :git => 'https://github.com/kf8a/ruby-openid.git'
gem 'rack-openid'
gem 'acts-as-taggable-on'
gem 'paperclip' 
gem 'aws-s3'
gem 'nokogiri'
gem 'RedCloth'
gem 'liquid'
gem 'formtastic'
# can we go back to the collective idea branch of awesome_nested_set
gem 'awesome_nested_set' #, :git => 'git://github.com/galetahub/awesome_nested_set.git'

gem 'jquery-rails' #, '>= 1.0.12'

gem 'workflow'

gem 'friendly_id'

gem 'parslet'

# for spreadsheet downloads
#gem 'spreadsheet'

# for creating bibtex formatted citations
gem 'bibtex-ruby'

#gem 'metric_fu'

gem 'jammit'

# versioning support for protocols
gem 'vestal_versions', :git => 'git://github.com/milkfarm/vestal_versions.git'
# :git => 'git://github.com/zapnap/vestal_versions.git' 
# :git => 'git://github.com/adamcooper/vestal_versions'

# offile manifest
# gem 'rack-offline'

gem 'dalli'

#gem 'central_logger'


#for coffeescript
gem 'therubyracer', :require => false
gem 'barista'

gem 'has_scope'

gem 'ris_parser', :git => 'git://github.com/kf8a/ris_parser.git'

gem 'thinking-sphinx'

group :production do
  #gem "sitemap_generator", "~> 3.1.1"
  gem 'exception_notification'
  gem 'unicorn'
  #gem 'puma'
end


group :development, :test  do
  # bundler requires these gems in development
  # gem "rails-footnotes"
  gem 'sqlite3-ruby'
#  gem 'silent-postgres'
  gem "shoulda", :git => 'git://github.com/thoughtbot/shoulda.git' 
  gem 'rspec-rails'
#  gem "rspec"
#  gem "annotate"
end

group :test do
  gem 'mocha'
  gem 'simplecov'
  gem 'simplecov-html'

  gem "shoulda-matchers" # to use rspec like syntax
  gem 'factory_girl_rails' #, :require => false
#  gem 'remarkable_activerecord', '>=4.0.0.alpha2'

  #Cucumber stuff
  gem 'capybara', '0.4.1.2'
  gem 'cucumber-rails' , :require => false
  gem 'spork'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'pickle'
end
