# frozen_string_literal: true

# Build an EML representation of a person record
class EmlPersonBuilder
  attr_reader :eml, :person

  def initialize(person)
    @person = person
  end

  def to_eml(eml = Builder::XmlMarkup.new, role = 'Investigator')
    @eml = eml
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
    eml.organizationName person.organization if person.organization.present?
  end

  def eml_phone(eml)
    eml.phone person.phone, 'phonetype' => 'phone' if person.phone
  end

  def eml_fax(eml)
    eml.phone person.fax, 'phonetype' => 'fax' if person.fax
  end

  def eml_email(eml)
    eml.electronicMailAddress person.email if person.email.present?
  end

  def eml_city(eml)
    eml.city person.city if person.city.present?
  end

  def eml_delivery_point(eml)
    eml.deliveryPoint person.street_address if person.street_address.present?
  end

  def eml_administrative_area(eml)
    eml.administrativeArea person.locale if person.locale.present?
  end

  def eml_postal_code(eml)
    eml.postalCode person.postal_code if person.postal_code.present?
  end

  def eml_county(eml)
    eml.country person.country if person.country.present?
  end

  def eml_address(eml)
    eml.address do
      eml_delivery_point(eml)
      eml_city(eml)
      eml_administrative_area(eml)
      eml_postal_code(eml)
      eml_county(eml)
    end
    eml
  end

  def eml_user_id(eml)
    # directory=  id=
    return unless person.orcid_id
    if person.orcid_id =~ /http/
      eml.userId person.orcid_id, directory: 'http://orcid.org'
    else
      eml.userId 'http://' + person.orcid_id, directory: 'http://orcid.org'
    end
  end

  def eml_individual_name(eml)
    eml.individualName do
      eml.givenName person.given_name if person.given_name.present?
      eml.surName person.sur_name if person.sur_name.present?
    end
    eml
  end
end
