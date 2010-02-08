class Theme < ActiveRecord::Base
  acts_as_nested_set
  
  has_and_belongs_to_many :datasets
  has_many :datatables
  
  def has_datatables?(study=nil)
    children_have_datatables = children.collect {|d| d.has_datatables?(study)}.include?(true)
    i_have_datatables = datatables.any?
    if study
      i_have_datatables = datatables.collect {|d| d.dataset.studies.include?(study)}.include?(true)
    end
    i_have_datatables || children_have_datatables
  end

end
