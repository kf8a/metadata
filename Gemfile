source 'https://rubygems.org'

gem 'rails', '~>4.2'

gem 'activerecord-session_store'
gem 'responders'

gem 'rake', '< 11.0'
gem 'capistrano', '~>2'
gem 'pg'
gem 'clearance'
gem 'acts-as-taggable-on'
gem 'paperclip', '~> 4'
gem 'nokogiri'
gem 'RedCloth'
gem 'formtastic'
gem 'country_select'
gem 'cube-ruby'

#gem 'doi', :git => 'git://github.com/kf8a/doi.git'

gem 'awesome_nested_set'

gem 'jquery-rails' 

#gem 'net-ssh'

gem 'workflow'

gem 'parslet'

# for spreadsheet downloads
#gem 'spreadsheet'

# for creating bibtex formatted citations
gem 'bibtex-ruby'

# versioning support for protocols
gem 'vestal_versions', :git => 'https://github.com/R1V3R5/vestal_versions'

gem 'dalli'

#gem 'central_logger'

gem 'has_scope', '<0.6'

gem 'ris_parser', :git => 'https://github.com/kf8a/ris_parser.git'

gem 'thinking-sphinx'
gem 'mysql2'

gem 'aws-sdk' #, '< 2.0'

gem "sitemap_generator"
group :production do
  gem 'exception_notification'
  gem 'unicorn'
 # gem 'newrelic_rpm'
end

gem 'therubyracer', :require => false
gem 'less-rails'
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'

gem 'prometheus-client' #, '~> 0.4.2'
gem 'web-console', group: :development

gem 'awesome_print'

group :development, :test  do
  gem "byebug"
  gem "spring"
  gem 'minitest'
  gem 'minitest-reporters', '>= 0.5.0'

  gem 'test-unit'
  gem 'meta_request'
  gem 'rspec-rails'
  gem 'rspec-its'
  gem "annotate"
end

group :test do
  gem "shoulda", :git => 'https://github.com/thoughtbot/shoulda.git' 
  gem "shoulda-matchers" # to use rspec like syntax
  gem 'factory_girl_rails'


  #Cucumber stuff
#  gem 'capybara'
#  gem 'cucumber-rails' , :require => false
#  gem 'pickle'
#  gem 'selenium-webdriver'
  gem 'database_cleaner'
end
