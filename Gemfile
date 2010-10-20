source 'http://rubygems.org'

gem 'rails', '3.0.1'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem "pg"
gem "rack-openid"
gem "fastercsv" unless RUBY_VERSION > "1.9"
gem "acts-as-taggable-on"
gem "paperclip"
gem 'nokogiri'
gem 'RedCloth'
gem 'thinking-sphinx',
  :git     => 'git://github.com/freelancing-god/thinking-sphinx.git',
  :branch  => 'rails3',
  :require => 'thinking_sphinx'

gem 'liquid'
gem "clearance"
gem 'formtastic'
gem 'zipruby'
gem 'less'
gem "subdomain-fu", :git => "git://github.com/nhowell/subdomain-fu.git"
gem 'thin'

gem 'metric_fu'

group :development do
  # bundler requires these gems in development
  # gem "rails-footnotes"
end

group :test do
  if RUBY_VERSION > "1.9"
    gem 'simplecov'
    gem 'simplecov-html'
  end
  gem "shoulda"
  gem "factory_girl" 

  gem "rspec", "=1.3.0"
  gem "rspec-rails"
end

group :cucumber do
  gem "shoulda"
  gem "factory_girl"

  gem 'cucumber-rails'
  gem 'database_cleaner'
  gem 'webrat'
end