# frozen_string_literal: true

# Permissions to download data
class Permission < ApplicationRecord
  belongs_to :user
  belongs_to :datatable
  belongs_to :owner, class_name: 'User'

  validates :user, :datatable, :owner, presence: true

  validates :user_id, uniqueness: { scope: %i[datatable_id owner_id] }
  validate :only_owners_can_set_permissions

  def self.permitted_users
    all.collect { |permission| permission.user unless permission.denied? }.compact
  end

  def denied?
    decision != 'approved'
  end

  def only_owners_can_set_permissions
    errors.add(:base, 'owners only') unless owner&.owns?(datatable)
  end
end
