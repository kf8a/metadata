class CoreArea < ActiveRecord::Base
  has_many :datatables

  scope :by_name, :order => 'name'
end
