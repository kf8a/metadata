class Person < ActiveRecord::Base
  has_many :affiliations
  has_many :lter_roles, :through => :affiliations, :conditions => ['role_type_id = ?', RoleType.find_by_name('lter')], :source => :role
  has_many :dataset_roles, :through => :affiliations, :conditions => ['role_type_id = ?', RoleType.find_by_name('lter_dataset')], :source => :role
  has_many :datasets, :through => :affiliations,  :source => :dataset
  has_many :scribbles
  has_many :protocols, :through => :scribbles
  
  has_many :data_contributions
  has_many :datatables, :through => :data_contributions
    
  accepts_nested_attributes_for :affiliations, :allow_destroy => true

  scope :by_sur_name, :order => 'sur_name'
  scope :by_sur_name_asc, :order => 'sur_name ASC'
  
  #acts_as_taggable
  
  def get_all_lter_roles
    lter_roles.collect {|x| x.name.singularize }
  end
  
  def get_committee_roles
    lter_roles.collect do |x|
      x.name.singularize if x.committee?
    end.compact
  end
  
  def only_emeritus?
    emeritus_roles = lter_roles.collect   {|role| role.emeritus? }
    emeritus_roles.reject! {|x| !x }
    emeritus_roles.size == lter_roles.size 
  end
  
  def normal_given_name
    friendly_name.presence || given_name
  end
  
  def full_name
    normal_given_name + " "  + sur_name
  end
  
  def last_name_first
    sur_name + ', ' + normal_given_name
  end
  
  def short_full_name
    full_name.truncate(33)
  end
    
  def usa_address?
    country.blank? || country.downcase == 'usa' || country.downcase == 'us'
  end
  
  def complete_address?
    !usa_address? || 
      (city.present? && street_address.present? && postal_code.present? && locale.present?)
  end
  
  def address
    if usa_address?
      "#{street_address} #{city}, #{locale} #{postal_code}"
    else
      "#{street_address}\n#{postal_code} #{city} #{country}"
    end
  end
  
  def self.find_all_with_dataset
    people = Person.order('sur_name').collect {|x| x if x.has_dataset?}
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
