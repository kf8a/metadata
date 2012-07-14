require 'strip_empty_sessions'
Metadata::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  # Use a different cache store in production
#  config.cache_store = :mem_cache_store, "thetford.kbs.msu.edu", {:compress => :true}
  config.cache_store = :dalli_store, "kalkaska.kbs.msu.edu", {:compress => true, :compress_threshold => 64*1024}


  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # configure common asset hash across all hosts
  # RELEASE_NUMBER = 1
  # config.action_controller.asset_path_template = proc { |asset_path|
  #     "/release-#{RELEASE_NUMBER}#{asset_path}"
  #   }
  # Enable serving of images, stylesheets, and javascripts from an asset server
  #config.action_controller.asset_host = "http://lter.kbs.msu.edu/dynamic"
  

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.middleware.insert_before ActiveRecord::SessionStore, 'StripEmptySessions', :key => config.secret_token, :path => "/", :httponly => true
end
