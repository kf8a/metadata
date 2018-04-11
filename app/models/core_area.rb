# The LTER core areas are managed by this class
class CoreArea < ApplicationRecord
  has_and_belongs_to_many :datatables
  # has_many :datatables, through: :core_areas_datatables

  scope :by_name, -> { order 'name' }
end

# == Schema Information
#
# Table name: core_areas
#
#  id   :integer         not null, primary key
#  name :string(255)
#
