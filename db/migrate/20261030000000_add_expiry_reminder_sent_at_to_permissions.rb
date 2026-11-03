# frozen_string_literal: true

# When the "your access ends in a week" email was sent, so it is sent once per expiry date
class AddExpiryReminderSentAtToPermissions < ActiveRecord::Migration[8.1]
  def change
    add_column :permissions, :expiry_reminder_sent_at, :datetime
  end
end
