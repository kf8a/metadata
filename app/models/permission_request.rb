# A request to access a datatable
class PermissionRequest < ApplicationRecord
  belongs_to :user
  belongs_to :datatable

  validates :user, :datatable, presence: true
  validates :user_id, uniqueness: { scope: :datatable_id }
end
