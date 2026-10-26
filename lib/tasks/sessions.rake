# frozen_string_literal: true

namespace :sessions do
  desc 'Delete sessions that have been idle past the sign-in timeout (Devise.timeout_in) plus a day'
  task trim: :environment do
    cutoff = (Devise.timeout_in + 1.day).ago
    deleted = ActiveRecord::SessionStore::Session.where(updated_at: ...cutoff).delete_all
    Rails.logger.info "sessions:trim deleted #{deleted} sessions idle since before #{cutoff}"
  end
end
