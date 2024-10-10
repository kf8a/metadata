Rails.application.config.session_store :cookie_store, key: '_lter_metadata_session'
Rails.application.config.action_dispatch.encrypted_cookie_salt =  Rails.application.credentials.encrypted_cookie_salt
Rails.application.config.action_dispatch.encrypted_signed_cookie_salt = Rails.application.credentials.encrypted_signed_cookie_salt
