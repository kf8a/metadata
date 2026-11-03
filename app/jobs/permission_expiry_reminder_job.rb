# frozen_string_literal: true

# Emails each user once, a week before their permission to download a datatable ends. Extending the
# permission resets the reminder for the new date. Run daily from config/recurring.yml.
class PermissionExpiryReminderJob < ApplicationJob
  queue_as :default

  def perform
    Permission.due_for_expiry_reminder.includes(:user, :datatable, :granted_by).find_each do |permission|
      PermissionMailer.expiring(permission).deliver_now
      permission.update!(expiry_reminder_sent_at: Time.current)
    end
  end
end
