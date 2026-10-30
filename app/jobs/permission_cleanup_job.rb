# frozen_string_literal: true

# Deletes download permissions that expired more than Permission::KEEP_EXPIRED_FOR ago. Until then an
# expired permission stays on the admin page, marked expired, so it can still be extended. Run daily
# from config/recurring.yml.
class PermissionCleanupJob < ApplicationJob
  queue_as :default

  def perform
    cutoff = Date.current - Permission::KEEP_EXPIRED_FOR
    deleted = Permission.where(expires_on: ...cutoff).delete_all
    Rails.logger.info "PermissionCleanupJob deleted #{deleted} permissions that expired before #{cutoff}"
  end
end
