# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!
OmniAuth.config.logger = Rails.logger
