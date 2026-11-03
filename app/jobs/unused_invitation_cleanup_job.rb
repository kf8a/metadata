# frozen_string_literal: true

# Deletes accounts an admin created for a new reader (PermissionsController) who never set a password,
# once the newest link they were sent has been expired for KEEP_AFTER_LINK_EXPIRES. Until then the admin
# page still lists them, and extending their access sends a fresh link. Deleting the account also
# deletes its permissions and invitations. Run daily from config/recurring.yml.
class UnusedInvitationCleanupJob < ApplicationJob
  queue_as :default

  KEEP_AFTER_LINK_EXPIRES = 30.days

  def perform
    cutoff = Devise.invite_for.ago - KEEP_AFTER_LINK_EXPIRES
    deleted = unused_accounts(cutoff).find_each.count(&:destroy!)
    Rails.logger.info "UnusedInvitationCleanupJob deleted #{deleted} accounts whose links expired before #{cutoff}"
  end

  private

  # Accounts still waiting on an invitation (devise_invitable's invitation_pending?) with none sent
  # since the cutoff, and never signed in
  def unused_accounts(cutoff)
    pending = DeviseInvitable::Invitation.pending.where(invitable_type: 'User')
    recent = pending.where('COALESCE(invitation_sent_at, invitation_created_at) >= ?', cutoff)
    User.where(id: pending.provisioning.select(:invitable_id), sign_in_count: [0, nil])
        .where.not(id: recent.select(:invitable_id))
  end
end
