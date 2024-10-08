# frozen_string_literal: true

# Represents a person in the system
class Person < ApplicationRecord
  has_many :affiliations, dependent: :destroy
  has_many :lter_roles, -> { where(['role_type_id = ?', RoleType.find_by(name: 'lter')]) },
           source: :role, through: :affiliations
  has_many :lno_roles, -> { where(['role_type_id = ?', RoleType.find_by(name: 'lno')]) },
           source: :role, through: :affiliations
  has_many :dataset_roles, -> { where ['role_type_id = ?', RoleType.find_by(name: 'lter_dataset')] },
           through: :affiliations, source: :role
  has_many :roles, through: :affiliations
  has_many :datasets, through: :affiliations, source: :dataset
  has_many :scribbles, dependent: :destroy
  has_many :protocols, through: :scribbles
  has_many :person_projects, dependent: :destroy
  has_many :people, through: :person_projects

  has_many :data_contributions, dependent: :destroy
  has_many :datatables, through: :data_contributions

  accepts_nested_attributes_for :affiliations, allow_destroy: true
  accepts_nested_attributes_for :lter_roles, allow_destroy: true

  scope :by_sur_name, -> { order 'sur_name' }
  scope :by_sur_name_asc, -> { order 'sur_name ASC' }

  def only_emeritus?
    lter_roles.all?(&:emeritus?)
  end

  def no_current_lno_role?
    lno_roles.first.nil? || !lno_roles.first.try(:left_on).nil?
  end

  def lno_affiliations
    Affiliation.joins(
      "join people on affiliations.person_id = people.id
      join roles on roles.id = affiliations.role_id
      join role_types on roles.role_type_id = role_types.id").
      where(person_id: self.id).where(role_types: {name: "lno"})
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
    "#{sur_name}, #{normal_given_name}"
  end

  def short_full_name
    full_name.truncate(33)
  end

  def usa_address?
    country.blank? || country.casecmp('usa').zero? || country.casecmp('us').zero?
  end

  def email=(val)
    super(val == "" ? nil : val)
  end

  def complete_address?
    !usa_address? ||
      (city.present? && street_address.present? &&
       postal_code.present? && locale.present?)
  end

  def address
    if usa_address?
      "#{street_address} #{city}, #{locale} #{postal_code}"
    else
      "#{street_address}\n#{postal_code} #{city} #{country}"
    end
  end

  def self.find_all_with_dataset
    people = Person.order('sur_name')
                   .collect { |person| person if person.dataset? }
    people.compact
  end

  def dataset?
    !dataset_roles.empty?
  end

  def to_lter_personneldb
    # TODO: fill this in
  end

  def to_eml(eml = Builder::XmlMarkup.new, role = 'Investigator')
    builder = EmlPersonBuilder.new(self)
    builder.to_eml(eml, role)
  end

  # def self.from_eml(person_eml)
  #   person = Person.new
  #   person.from_eml(person_eml)
  #
  #   # TODO: remove self save
  #   person.save
  #
  #   person
  # end
  #
  # def from_eml(person_eml)
  #   basic_attributes_from_eml(person_eml)
  #   address_from_eml(person_eml.css('address'))
  #   person_eml.css('phone').each { |phone_eml| phone_from_eml(phone_eml) }
  #   role_from_name(person_eml.css('role').text)
  # end
  #
  def to_lno_active
    [
      lno_name,
      'LTER', 'KBS',
      given_name, sur_name,
      full_name, email, lno_roles.map(&:name).flatten.join('|'),
      orcid_id, 'urn:lter:lterCurrentMember'
    ]
  end

  def to_lno_inactive
    [
      '', lno_name,
      'LTER', 'KBS',
      given_name, sur_name,
      full_name, email, lno_roles.map(&:name).flatten.join('|'),
      orcid_id, 'urn:lter:lterFormerMember'
    ]
  end

  private

  def basic_attributes_from_eml(person_eml)
    self.given_name   = person_eml.css('individualName givenName').collect(&:text).join(' ')
    self.sur_name     = person_eml.css('individualName surName').text
    self.organization = person_eml.css('organizationName').text
    self.email        = person_eml.css('electronicMailAddress').text
  end

  def address_from_eml(address_eml)
    self.street_address = address_eml.css('deliveryPoint').text
    self.city           = address_eml.css('city').text
    self.locale         = address_eml.css('administrativeArea').text
    self.postal_code    = address_eml.css('postalCode').text
    self.country        = address_eml.css('country').text
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

  def role_from_name(role_name)
    role_to_add = Role.find_or_create_by_name(role_name)
    Affiliation.create!(person: self, role: role_to_add) if role_to_add.present?
  end
end
