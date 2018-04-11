# RoleType differntiates between dataset roles and project roles
class RoleType < ApplicationRecord
  has_many :roles

  validates :name, presence: true, uniqueness: true
end
