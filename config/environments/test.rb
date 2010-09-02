# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = true #this needs to be true to test caching

# Tell ActionMailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test
config.action_mailer.default_url_options = {:host => 'localhost:3000'} 

config.gem 'simplecov'
config.gem 'simplecov-html'
config.gem "shoulda", :lib => false
config.gem "factory_girl" , :lib => false

config.gem "rspec", :lib => false # , :version => ">= 1.2.0"
config.gem "rspec-rails", :lib => false #, :version => ">= 1.2.0"
