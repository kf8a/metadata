class Study < ActiveRecord::Base

  has_and_belongs_to_many :datasets
  has_many :datatables
  has_many :treatments
  has_many :study_urls
    
  acts_as_nested_set

  named_scope :by_weight, :order => 'weight'
  named_scope :by_id,     :order => 'id'
  
  def study_url(website)
    study_urls.find(:first, :conditions => ['website_id = ?', website.id]).url
  end
    
  # returns true if one or more of the tables passed is part of the current study
  def include_datatables?(table_query = [])
    (self_and_descendants_datatables & table_query).any?
  end
  
  def self.find_all_with_datatables(tables = [], options = {})
    self.all(options).collect {|x| x.include_datatables?(tables)  ? x : nil}.compact
  end
  
  def self.find_all_roots_with_datatables(tables=[], options={})
    self.roots(options).collect {|x| x.include_datatables?(tables) ? x : nil}.compact
  end
  
  private
  
  def self_and_descendants_datatables
    descendants.collect {|d| d.datatables }.flatten + datatables
  end
  
  def self_and_descendants_themed_datatables
    my_datatables = descendants.collect {|d| d.datatables }.flatten
    all_datatables = my_datatables + datatables    
    all_datatables.collect {|d| d.theme ? d : nil}.compact
  end
  
end
