class Person < ActiveRecord::Base
  has_many :affiliations
  has_many :lter_roles, :through => :affiliations, :conditions => ['role_type_id = ?', RoleType.find_by_name('lter')], :source => :role
  has_many :dataset_roles, :through => :affiliations, :conditions => ['role_type_id = ?', RoleType.find_by_name('lter_dataset')], :source => :role
  has_many :roles, :through => :affiliations
  has_many :datasets, :through => :affiliations,  :source => :dataset
  has_many :scribbles
  has_many :protocols, :through => :scribbles

  has_many :data_contributions
  has_many :datatables, :through => :data_contributions

  accepts_nested_attributes_for :affiliations, :allow_destroy => true

  scope :by_sur_name, :order => 'sur_name'
  scope :by_sur_name_asc, :order => 'sur_name ASC'

  def self.from_eml(person_eml)
    person = Person.new
    person.from_eml(person_eml)
    person.save

    person
  end

  def from_eml(person_eml)
    self.given_name = person_eml.css('individualName givenName').collect{ |element| element.text }.join(' ')
    self.sur_name = person_eml.css('individualName surName').text
    self.organization = person_eml.css('organizationName').text
    self.street_address = person_eml.css('address deliveryPoint').text

    self.city = person_eml.css('address city').text
    self.locale = person_eml.css('address administrativeArea').text
    self.postal_code = person_eml.css('address postalCode').text
    self.country = person_eml.css('address country').text

    person_eml.css('phone').each { |phone_eml| phone_from_eml(phone_eml) }

    self.email = person_eml.css('electronicMailAddress').text
    save
    role_name = person_eml.css('role').text
    role_to_add = Role.find_or_create_by_name(role_name)
    self.affiliations.create!(:role => role_to_add) if role_to_add.present?
  end

  def phone_from_eml(phone_eml)
    phone_number = phone_eml.text
    phone_type = phone_eml.attributes['phonetype'].try(:value)
    if phone_type == 'phone'
      self.phone = phone_number
    elsif phone_type == 'fax'
      self.fax = phone_number
    end
  end

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
    "#{normal_given_name} #{sur_name}"
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
    people = Person.order('sur_name').collect { |person| person if person.has_dataset? }
    people.compact
  end

  def has_dataset?
    self.dataset_roles.size > 0
  end

  def to_eml(eml = Builder::XmlMarkup.new)
    eml.associatedParty do
      eml_individual_name(eml)
      eml.organizationName organization unless organization.blank?
      eml_address(eml)
      if phone
        eml.phone phone, 'phonetype' => 'phone'
      end
      if fax
        eml.phone fax, 'phonetype' => 'fax'
      end
      eml.electronicMailAddress email  unless email.blank?
      eml.role lter_roles.first.try(:name).try(:singularize)
    end
  end

  def eml_individual_name(eml)
    eml.individualName do
      eml.givenName given_name unless given_name.blank?
      eml.surName sur_name  unless sur_name.blank?
    end
    eml
  end

  def eml_address(eml)
    eml.address  do
      eml.deliveryPoint street_address  unless street_address.blank?
      eml.city city  unless city.blank?
      eml.administrativeArea locale unless locale.blank?
      eml.postalCode postal_code unless postal_code.blank?
      eml.country country unless country.blank?
    end
    eml
  end

  def eml
    @eml ||= Builder::XmlMarkup.new
  end

  def to_lter_personneldb
    #TODO fill this in
  end

end




# == Schema Information
#
# Table name: people
#
#  id               :integer         not null, primary key
#  person           :string(255)
#  sur_name         :string(255)
#  given_name       :string(255)
#  middle_name      :string(255)
#  friendly_name    :string(255)
#  title            :string(255)
#  sub_organization :string(255)
#  organization     :string(255)
#  street_address   :string(255)
#  city             :string(255)
#  locale           :string(255)
#  country          :string(255)
#  postal_code      :string(255)
#  phone            :string(255)
#  fax              :string(255)
#  email            :string(255)
#  url              :string(255)
#  deceased         :boolean
#  open_id          :string(255)
#
