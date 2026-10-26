# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

if Rails.env.development?
  Metadata::Application.config.session_store :cookie_store, key: '_metadata_session'
else
  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  Metadata::Application.config.session_store :active_record_store, key: '_metadata_session'
end

# Devise's :timeoutable records activity by changing a hash nested inside the session. Rails gets a
# shallow copy of the stored row's data, so that change also alters the store's own copy, the store
# sees nothing to save, and last_request_at only persists when something else in the session changes.
# Handing out a deep copy makes every request that records activity get saved.
module SessionDataDeepCopy
  def find_session(request, id)
    id, data = super
    [id, data.deep_dup]
  end
end
ActionDispatch::Session::ActiveRecordStore.prepend(SessionDataDeepCopy)
