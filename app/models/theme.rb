class Theme < ActiveRecord::Base
  acts_as_nested_set
  
  has_and_belongs_to_many :datasets
  has_many :datatables
  
  def datatables?(study=nil)
    children_have_datatables = children.collect {|d| d.datatables?(study)}.include?(true)
    i_have_datatables = datatables.any?
    if study
      i_have_datatables = datatables.collect {|d| d.dataset.studies.include?(study)}.include?(true)
    end
    i_have_datatables || children_have_datatables
  end
  
  def include_datatables?(test_datatables=[])
    my_datatables = descendants.collect {|d| d.datatables }.flatten
    my_datatables = my_datatables + datatables

    (my_datatables & test_datatables).any?
  end

end
