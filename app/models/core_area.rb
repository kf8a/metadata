class CoreArea < ActiveRecord::Base
  has_many :datatables

  scope :by_name, :order => 'name'
end


# == Schema Information
#
# Table name: core_areas
#
#  id   :integer         not null, primary key
#  name :string(255)
#

