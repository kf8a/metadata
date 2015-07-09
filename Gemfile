source 'https://rubygems.org'

gem 'rails', '~>4.2'

gem 'activerecord-session_store'

gem 'rake'
gem 'capistrano' 
gem 'pg'
gem 'foreigner'
gem 'clearance', '1.0.0.rc7'
gem 'ruby-openid', :git => 'https://github.com/kf8a/ruby-openid.git'
gem 'rack-openid'
gem 'open_id_authentication'
gem 'acts-as-taggable-on'
gem 'paperclip' 
gem 'nokogiri'
gem 'RedCloth'
gem 'formtastic'
gem 'simple_form'
gem 'country_select'
gem 'cube-ruby'

gem 'exception_notification'

#gem 'mercury-rails'

# can we go back to the collective idea branch of awesome_nested_set
gem 'awesome_nested_set' #, :git => 'git://github.com/galetahub/awesome_nested_set.git'

gem 'jquery-rails' 

gem 'workflow'

gem 'friendly_id'

gem 'parslet'

# for spreadsheet downloads
#gem 'spreadsheet'

# for creating bibtex formatted citations
gem 'bibtex-ruby'

# versioning support for protocols
gem 'vestal_versions', :git => 'git://github.com/laserlemon/vestal_versions'
# gem 'vestal_versions', :git => 'git://github.com/milkfarm/vestal_versions.git'

gem 'dalli'

#gem 'central_logger'

gem 'has_scope'

gem 'ris_parser', :git => 'git://github.com/kf8a/ris_parser.git'

gem 'thinking-sphinx'
gem 'mysql2'
# gem 'cache_digests'


gem 'aws-sdk'
gem "sitemap_generator"
group :production do
  # gem 'exception_notification'
  gem 'unicorn'
 # gem 'newrelic_rpm'
end

group :assets do
  gem 'therubyracer', :require => false
	gem 'less-rails'
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
end

group :development, :test  do
  gem 'minitest'
  gem 'test-unit'
  gem 'meta_request'
  gem 'rspec-rails'
  gem 'rspec'
  gem "shoulda", :git => 'git://github.com/thoughtbot/shoulda.git' 
  gem "annotate"

  gem 'sqlite3'
end

group :test do
  gem "shoulda-matchers" # to use rspec like syntax
  gem 'factory_girl'
  gem 'factory_girl_rails'

  #Cucumber stuff
  gem 'capybara'
  gem 'cucumber-rails' , :require => false
  gem 'pickle'
#  gem 'spork'
  gem 'selenium-webdriver'
  gem 'database_cleaner'
end
