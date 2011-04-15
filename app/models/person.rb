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

  def get_committee_roles
    lter_roles.collect { |role| role.committee_role_name }.compact
  end

  def only_emeritus?
    lter_roles.all? { |role| role.emeritus? }
  end

  def expanded_name
    "#{given_name} #{middle_name} #{sur_name}"
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

end
