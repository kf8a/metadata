class Study < ActiveRecord::Base
  has_many :treatments
  has_and_belongs_to_many :datasets
  
  def include_datatables?(datatables = [])
    return true if datatables.empty?
    datasets.collect  {|dataset| (dataset.datatables & datatables).any? }.include?(true)
  end
end
