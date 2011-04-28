xml.address 'scope' => 'document' do
  xml.deliveryPoint person.organization if person.organization
  xml.deliveryPoint person.street_address if person.street_address
  xml.city person.city if person.city
  xml.administrativeArea person.locale if person.locale
  xml.postalCode person.postal_code if person.postal_code
  xml.country person.country if person.country
end