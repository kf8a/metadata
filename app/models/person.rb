class Person < ActiveRecord::Base
  has_many :affiliations
  has_many :lter_roles, :through => :affiliations, :conditions => ['role_type_id = ?', RoleType.find_by_name('lter')], :source => :role
  has_many :dataset_roles, :through => :affiliations, :conditions => ['role_type_id = ?', RoleType.find_by_name('dataset')], :source => :role
  has_many :datasets, :through => :affiliations,  :source => :dataset
  has_many :scribbles
  has_many :protocols, :through => :scribbles
    
  accepts_nested_attributes_for :affiliations, :allow_destroy => true
  
  #acts_as_taggable
  
  def get_all_lter_roles
    roles = lter_roles.collect {|x| x.name.singularize }
    roles.join(', ')
  end
  
  def full_name
    name = given_name
    if friendly_name && friendly_name.size > 0
      name = friendly_name
    end
    name += " "
    name += sur_name
    return name
  end
  
  #hack
  def short_full_name 
    fn = full_name
    chars = fn.mb_chars
    (chars.length > 30 ? chars[0...30] + '...' : chars).to_s
  end
    
  def unique_dataset_role_names
    self.dataset_roles.map(&:name).sort.uniq
  end
  
  def address
    address = city || ''
    address = address + ' '
    address = street_address || ''
    return address
  end
  
  def self.find_all_with_dataset
    people = Person.all.collect {|x| x if x.has_dataset?}
    people.compact
  end
    
  def has_dataset?
    self.dataset_roles.size > 0
  end
  
  # def lter_role_ids=(role_ids)
  #   affiliations.each do |affiliation|
  #     affiliation.destroy unless role_ids.include? affiliation.id
  #   end
  #   
  #   role_ids.each do |role_id|
  #     self.affiliations.create(:role_id => role_id) unless affiliations.any? {|d| d.role_id == role_id}
  #   end
  # end
  
end
