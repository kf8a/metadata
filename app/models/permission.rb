# frozen_string_literal: true

# Permission for a user to download a restricted or members-only datatable, granted by an admin.
# Access ends after expires_on; without a date it does not expire.
class Permission < ApplicationRecord
  # Owners used to approve or deny each user; the column is dropped once this has been deployed
  self.ignored_columns += ['decision']

  DEFAULT_LIFETIME = 90.days

  # How long before the expiry date the reminder email goes out
  REMIND_BEFORE = 7.days

  # How long an expired permission stays listed (and can be extended) before PermissionCleanupJob deletes it
  KEEP_EXPIRED_FOR = 30.days

  # Label => days, or 'never'
  LIFETIME_CHOICES = { '30 days' => '30', '90 days' => '90', '1 year' => '365', 'No expiry' => 'never' }.freeze

  belongs_to :user
  belongs_to :datatable
  # The admin who granted or last extended it; permissions carried over from owner approvals name the owner.
  # Empty once that user is deleted: the permission stays.
  belongs_to :granted_by, class_name: 'User', foreign_key: :owner_id, inverse_of: false, optional: true

  validates :user_id, uniqueness: { scope: :datatable_id }
  validate :granted_by_an_admin, on: :create

  scope :active, -> { where(expires_on: nil).or(where(expires_on: Date.current..)) }
  # Active permissions ending within REMIND_BEFORE whose reminder has not been sent yet
  scope :due_for_expiry_reminder, lambda {
    active.where(expires_on: ..(Date.current + REMIND_BEFORE), expiry_reminder_sent_at: nil)
  }

  # A new expiry date gets its own reminder
  before_save -> { self.expiry_reminder_sent_at = nil }, if: :will_save_change_to_expires_on?

  # The expiry date for one of LIFETIME_CHOICES; anything else gets the default
  def self.expiry_for(choice)
    return nil if choice == 'never'

    days = LIFETIME_CHOICES.value?(choice) ? choice.to_i.days : DEFAULT_LIFETIME
    Date.current + days
  end

  def active?
    expires_on.nil? || expires_on >= Date.current
  end

  private

  def granted_by_an_admin
    errors.add(:granted_by, 'must be an admin') unless granted_by&.admin?
  end
end
