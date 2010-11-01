Given /^the local venue type exists$/ do
  ven = VenueType.find(1) rescue nil
  unless ven
    ven = VenueType.new
    ven.id = 1
    ven.name = "local"
    ven.save
  end
end
