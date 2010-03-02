class Study < ActiveRecord::Base
  has_many :treatments
  has_and_belongs_to_many :datasets
  has_many :datatables
  
  acts_as_nested_set
  
  def include_datatables?(table_query = [])
    (datatables & table_query).any?
  end
  
  def self.find_all_with_datatables(tables = [], options = {})
    self.all.collect {|x| x.include_datatables?(tables)  ? x : nil}.compact
  end
end
