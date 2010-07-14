# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

if RUBY_VERSION > '1.9'
  Encoding.default_internal = 'utf-8'
  Encoding.default_external = 'utf-8'
end

Rails::Initializer.run do |config|
  config.gem "fastercsv" unless RUBY_VERSION > "1.9"
  config.gem "acts-as-taggable-on", :source => "http://gemcutter.org"
  config.gem "paperclip"
  config.gem 'nokogiri'
  config.gem 'RedCloth'
  config.gem 'thinking-sphinx', :lib     => 'thinking_sphinx'
  config.gem 'liquid'
  config.gem "clearance"
  config.gem 'formtastic'
 
  config.gem "shoulda", :lib => false
  config.gem "factory_girl" , :lib => false
 
  config.gem 'subdomain-fu'
  #config.gem "matthuhiggins-foreigner", :lib => "foreigner"
  
  # Settings in config/environments/* take precedence over those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
end

SubdomainFu.tld_sizes = {:development => 0,
                         :cucumber => 0,
                         :test => 0,
                         :production => 4} # set all at once (also the defaults)


OpenIdAuthentication.store = :file
Struct.new('Crumb', :url, :name)

