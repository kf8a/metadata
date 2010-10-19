source :gemcutter
gem "rails", "=2.3.10"
gem "pg"
gem "rack-openid"
gem "fastercsv" unless RUBY_VERSION > "1.9"
gem "acts-as-taggable-on"
gem "paperclip"
gem 'nokogiri'
gem 'RedCloth'
gem 'thinking-sphinx', "=1.3.18"
gem 'liquid'
gem "clearance"
gem 'formtastic'
gem 'zipruby'
gem 'less'
gem 'subdomain-fu'
gem 'thin'

gem 'rcov'  #this is called from rake, but should only be called in testing not production

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