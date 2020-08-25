# frozen_string_literal: true

# RoleType differntiates between dataset roles and project roles
class RoleType < ApplicationRecord
  has_many :roles, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
