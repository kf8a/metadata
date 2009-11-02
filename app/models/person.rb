class Person < ActiveRecord::Base
  has_many :affiliations
  has_many :lter_roles, :through => :affiliations, :conditions => ['role_type_id = ?', RoleType.find_by_name('lter')], :source => :role
  has_many :dataset_roles, :through => :affiliations, :conditions => ['role_type_id = ?', RoleType.find_by_name('dataset')], :source => :role
  has_many :datasets, :through => :affiliations,  :source => :dataset
  has_many :scribbles
  has_many :protocols, :through => :scribbles
    
  accepts_nested_attributes_for :affiliations, :allow_destroy => true
  
  #acts_as_taggable
  
  def full_name
    name = given_name
    if friendly_name && friendly_name.size > 0
      name = friendly_name
    end
    name += " "
    name += sur_name
    return name
  end
    
  def unique_dataset_role_names
    self.dataset_roles.map(&:name).sort.uniq
  end
  
  def address
    address = city || ' '
    address = address + ' '
    address = street_address || ' '
    return address
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
