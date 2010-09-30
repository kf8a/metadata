# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true

# Enable serving of images, stylesheets, and javascripts from an asset server
#config.action_controller.asset_host                  = "http://lter.kbs.msu.edu/dynamic"

config.action_mailer.default_url_options = {:host => 'glbrc.kbs.msu.edu'}
# Disable delivery errors, bad email addresses will be ignored
# config.action_mailer.raise_delivery_errors = false

#ActionController::AbstractRequest.relative_url_root = "/dynamic"

#ExceptionNotifier.exception_recipients = %w(bohms@msu.edu)