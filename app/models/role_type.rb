class RoleType < ActiveRecord::Base
  has_many :roles

  validates :name, :presence => true, :uniqueness => true
end
