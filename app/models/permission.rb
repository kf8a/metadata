# frozen_string_literal: true

# Permissions to download data
class Permission < ApplicationRecord
  belongs_to :user
  belongs_to :datatable
  belongs_to :owner, class_name: 'User'

  validates :user, :datatable, :owner, presence: true

  validates :user_id, uniqueness: true, scope: %i[datatable_id owner_id]
  validate :only_owners_can_set_permissions
  validate :user_exists?
  validate :datatable_exists?
  validate :owner_exists?

  def self.permitted_users
    all.collect { |permission| permission.user unless permission.denied? }.compact
  end

  def denied?
    decision != 'approved'
  end

  def only_owners_can_set_permissions
    errors[:base] << 'owners only' unless owner.try(:owns?, datatable)
  end

  def user_exists?
    return if user && User.find(user.id)

    errors[:base] << 'user must exist'
  end

  def owner_exists?
    return if owner && User.find(owner.id)

    errors[:base] << 'owner must exist'
  end

  def datatable_exists?
    return if datatable && Datatable.find(datatable.id)

    errors[:base] << 'datatable must exist'
  end
end
