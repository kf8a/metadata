# frozen_string_literal: true

require File.expand_path('./boot', __dir__)

require 'rails/all'

require 'rack'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Metadata
  class Application < Rails::Application
    config.load_defaults 7.1
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.cache_store = :file_store, 'tmp/cache'

    # Turbo only renders form replies that are redirects or 4xx/5xx errors
    config.responders.error_status = :unprocessable_content
    config.responders.redirect_status = :see_other

    # The database has things schema.rb can't describe (extensions, the topology schema, and functions
    # such as nanoid() used in column defaults), so it is dumped as SQL to db/structure.sql. Every schema
    # is dumped, not only those on the search path, so the extensions' own schemas come along.
    config.active_record.schema_format = :sql
    config.active_record.dump_schemas = :all
  end
end

# Maybe these belong here
Struct.new('Crumb', :url, :name)
