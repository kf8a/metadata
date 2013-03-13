source 'http://rubygems.org'

gem 'rails', '3.2.12'

gem 'rake'
gem 'capistrano' 
gem 'pg'
gem 'foreigner'
gem 'clearance', '1.0.0.rc4'
gem 'ruby-openid', :git => 'https://github.com/kf8a/ruby-openid.git'
gem 'rack-openid'
gem 'acts-as-taggable-on'
gem 'paperclip' 
gem 'nokogiri'
gem 'RedCloth'
gem 'liquid'
gem 'formtastic'
gem 'simple_form'
gem 'country_select'
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

#gem 'jammit'

# versioning support for protocols
gem 'vestal_versions', :git => 'git://github.com/milkfarm/vestal_versions.git'
# :git => 'git://github.com/zapnap/vestal_versions.git' 
# :git => 'git://github.com/adamcooper/vestal_versions'

gem 'dalli'

#gem 'central_logger'

gem 'has_scope'

gem 'ris_parser', :git => 'git://github.com/kf8a/ris_parser.git'

gem 'thinking-sphinx'

#gem 'cache_digests'

group :production do
  #gem "sitemap_generator", "~> 3.1.1"
  gem 'exception_notification'
  gem 'unicorn'
  gem 'aws-sdk'
  #gem 'puma'
 # gem 'newrelic_rpm'
end

group :assets do
  gem 'therubyracer', :require => false
	gem 'less-rails'
  gem 'sass-rails', "  ~> 3.2.3"
  gem 'coffee-rails', "~> 3.2.1"
  gem 'uglifier', '>= 1.0.3'
end


group :development, :test  do
  gem 'sqlite3-ruby'
  gem "shoulda", :git => 'git://github.com/thoughtbot/shoulda.git' 
  gem 'rspec-rails'
  gem "annotate"
end

group :test do
  #gem 'mocha'
  gem 'simplecov'
  gem 'simplecov-html'

  gem "shoulda-matchers" # to use rspec like syntax
  gem 'factory_girl_rails' #, :require => false

  #Cucumber stuff
  gem 'capybara', '0.4.1.2'
  gem 'cucumber-rails' , :require => false
  gem 'spork'
  gem 'launchy'
  gem 'database_cleaner'
  gem 'pickle'
end
