class CoreArea < ActiveRecord::Base
  has_many :datatables

  named_scope :by_name, :order => 'name'
end
