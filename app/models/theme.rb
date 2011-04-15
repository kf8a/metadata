class Theme < ActiveRecord::Base
  acts_as_nested_set
  
  has_and_belongs_to_many :datasets
  has_many :datatables

  scope :by_weight, :order => :weight
  scope :by_name, :order => 'name'
  
  def datatables?(study=nil)
    children_have_datatables = children.collect {|d| d.datatables?(study)}.include?(true)
    i_have_datatables = datatables.any?
    if study
      i_have_datatables = datatables_in_study(study).any?
    end
    i_have_datatables || children_have_datatables
  end
  
  def include_datatables?(test_datatables=[])
     my_datatables = self_and_descendants_datatables
    (my_datatables & test_datatables).any?
  end
  
  def include_datatables_from_study?(test_datatables, study)
    my_datatables = self_and_descendants_datatables
    datatables_in_study = my_datatables.collect {|table| table if table.study == study }

    (test_datatables & datatables_in_study).any?
  end
  
  def self_and_descendants_datatables
    my_datatables = descendants.collect {|d| d.datatables }.flatten
    my_datatables + datatables
  end
  
  def datatables_in_study(study, test_datatables=[])
    if test_datatables.any?
      datatables.collect {|table| table if table.study == study and test_datatables.include?(table)}.compact
    else
      datatables.collect {|table| table if table.study == study }.compact
    end
  end
end

# == Schema Information
#
# Table name: themes
#
#  id        :integer         not null, primary key
#  name      :string(255)
#  weight    :integer
#  parent_id :integer
#  lft       :integer
#  rgt       :integer
#

