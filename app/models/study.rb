class Study < ActiveRecord::Base
  has_many :treatments
  has_and_belongs_to_many :datasets
  has_many :datatables
  
  acts_as_nested_set
  
  def include_datatables?(table_query = [])
    (self_and_descendants_datatables & table_query).any?
  end
  
  def self.find_all_with_datatables(tables = [], options = {})
    # TODO optimization
    # table_ids = tables.collect(&:study_id).compact.uniq
    # if table_ids.empty?
    #   self.all
    # else
    #   self.find_by_sql("select * from studies where id in (#{table_ids.join(',')})")
    # end
    self.all(options).collect {|x| x.include_datatables?(tables)  ? x : nil}.compact
  end
  
  def self.find_all_roots_with_datatables(tables=[], options={})
    self.roots(options).collect {|x| x.include_datatables?(tables) ? x : nil}.compact
  end
  
  private
  
  def self_and_descendants_datatables
    my_datatables = descendants.collect {|d| d.datatables }.flatten
    my_datatables + datatables
  end
  
  def self_and_descendants_themed_datatables
    my_datatables = descendants.collect {|d| d.datatables }.flatten
    all_datatables = my_datatables + datatables    
    all_datatables.collect {|d| d.theme ? d : nil}.compact
  end
  
end
