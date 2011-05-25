class RoleType < ActiveRecord::Base
  has_many :roles

  validates :name, :presence => true, :uniqueness => true
end


# == Schema Information
#
# Table name: role_types
#
#  id   :integer         not null, primary key
#  name :string(255)
#

