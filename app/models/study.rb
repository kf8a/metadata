class Study < ActiveRecord::Base
  has_many :treatments
  has_and_belongs_to_many :datasets
  has_many :datatables
  
  acts_as_nested_set
  
  def include_datatables?(table_query = [])
    (datatables & table_query).any?
  end
end
