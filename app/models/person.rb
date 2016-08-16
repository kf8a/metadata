# Represents a person in the system
class Person < ActiveRecord::Base
  has_many :affiliations, dependent: :destroy
  has_many :lter_roles, -> { where(['role_type_id = ?', RoleType.find_by(name: 'lter')]) },
           source: :role, through: :affiliations
  has_many :dataset_roles, -> { where ['role_type_id = ?', RoleType.find_by(name: 'lter_dataset')] },
           through: :affiliations, source: :role
  has_many :roles, through: :affiliations
  has_many :datasets, through: :affiliations, source: :dataset
  has_many :scribbles
  has_many :protocols, through: :scribbles

  has_many :data_contributions
  has_many :datatables, through: :data_contributions

  accepts_nested_attributes_for :affiliations, allow_destroy: true

  scope :by_sur_name, -> { order 'sur_name' }
  scope :by_sur_name_asc, -> { order 'sur_name ASC' }

  def self.from_eml(person_eml)
    person = Person.new
    person.from_eml(person_eml)

    # TODO: remove self save
    person.save

    person
  end

  def from_eml(person_eml)
    basic_attributes_from_eml(person_eml)
    address_from_eml(person_eml.css('address'))
    person_eml.css('phone').each { |phone_eml| phone_from_eml(phone_eml) }
    role_from_name(person_eml.css('role').text)
  end

  def only_emeritus?
    lter_roles.all?(&:emeritus?)
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
    country.blank? || country.casecmp('usa') == 0 || country.casecmp('us') == 0
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
    dataset_roles.size > 0
  end

  def to_eml(eml = Builder::XmlMarkup.new, role = 'Investigator')
    eml.associatedParty do
      eml_party(eml)
      eml.role role
    end
  end

  def eml_party(eml)
    eml_individual_name(eml)
    eml_organization(eml)
    eml_address(eml)
    eml_phone(eml)
    eml_fax(eml)
    eml_email(eml)
    eml_user_id(eml)
    eml
  end

  def eml_organization(eml)
    eml.organizationName organization unless organization.blank?
  end

  def eml_phone(eml)
    eml.phone phone, 'phonetype' => 'phone' if phone
  end

  def eml_fax(eml)
    eml.phone fax, 'phonetype' => 'fax' if fax
  end

  def eml_email(eml)
    eml.electronicMailAddress email unless email.blank?
  end

  def eml_address(eml)
    eml.address do
      eml.deliveryPoint street_address unless street_address.blank?
      eml.city city unless city.blank?
      eml.administrativeArea locale unless locale.blank?
      eml.postalCode postal_code unless postal_code.blank?
      eml.country country unless country.blank?
    end
    eml
  end

  def eml_user_id(eml)
    eml.userid orchid_id if orchid_id
  end

  def to_lter_personneldb
    # TODO: fill this in
  end

  private

  def eml
    @eml ||= ::Builder::XmlMarkup.new
  end

  def eml_individual_name(eml)
    eml.individualName do
      eml.givenName given_name unless given_name.blank?
      eml.surName sur_name unless sur_name.blank?
    end
    eml
  end

  def basic_attributes_from_eml(person_eml)
    self.given_name   = person_eml.css('individualName givenName').collect(&:text).join(' ')
    self.sur_name     = person_eml.css('individualName surName').text
    self.organization = person_eml.css('organizationName').text
    self.email        = person_eml.css('electronicMailAddress').text
  end

  def role_from_name(role_name)
    role_to_add = Role.find_or_create_by_name(role_name)
    Affiliation.create!(person: self, role: role_to_add) if role_to_add.present?
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
