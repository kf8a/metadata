# frozen_string_literal: true

# Deletes sessions that have been idle past the longest sign-in timeout (Devise.timeout_in, the
# admin limit) plus a day, so a live session is never removed. Run daily from config/recurring.yml,
# or by hand with `rake sessions:trim`.
class SessionsTrimJob < ApplicationJob
  queue_as :default

  def perform
    cutoff = (Devise.timeout_in + 1.day).ago
    deleted = ActiveRecord::SessionStore::Session.where(updated_at: ...cutoff).delete_all
    Rails.logger.info "SessionsTrimJob deleted #{deleted} sessions idle since before #{cutoff}"
  end
end
