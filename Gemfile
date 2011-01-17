source 'http://rubygems.org'

gem 'rails', '3.0.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'capistrano'
gem 'newrelic_rpm'
gem 'pg'
gem 'rack-openid'
gem 'acts-as-taggable-on'
gem 'paperclip'
gem 'nokogiri'
gem 'RedCloth'
gem 'thinking-sphinx',
  :git     => 'git://github.com/freelancing-god/thinking-sphinx.git',
  :branch  => 'rails3',
  :require => 'thinking_sphinx'

gem 'liquid'
gem 'clearance', :git => 'git://github.com/thoughtbot/clearance.git'
gem 'formtastic'
#gem 'zipruby'
gem 'less'
gem 'subdomain-fu', :git => 'git://github.com/nhowell/subdomain-fu.git'
gem 'awesome_nested_set', :git => 'git://github.com/galetahub/awesome_nested_set.git'
gem 'thin'
gem 'jquery-rails', '>= 0.2.6'
if RUBY_VERSION < "1.9"
  gem 'fastercsv'
end

gem "transitions", :require => ["transitions", "active_record/transitions"]

#Gets rid of annoying UTF-8 string error in rack
gem "escape_utils"

gem 'metric_fu'

group :development, :test  do
  # bundler requires these gems in development
  # gem "rails-footnotes"
  gem 'sqlite3-ruby'
end

group :test do
  #if RUBY_VERSION > "1.9"
    gem 'simplecov'
    gem 'simplecov-html'
  #end
  gem 'sqlite3-ruby'

  gem "shoulda"
  gem "factory_girl"
  gem 'factory_girl_rails'

  gem "rspec", "=1.3.0"
  gem "rspec-rails"

  #Cucumber stuff
  gem 'capybara'
  gem "shoulda"
  gem "factory_girl"
  gem 'cucumber-rails'
  gem 'spork'
  gem 'launchy'
  gem 'database_cleaner'
end

group :production do
  gem 'memcache-client'
end
