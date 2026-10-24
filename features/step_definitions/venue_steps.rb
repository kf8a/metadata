Given(/^the local venue type exists$/) do
  ven = begin
    VenueType.find(1)
  rescue StandardError
    nil
  end
  unless ven
    ven = VenueType.new
    ven.id = 1
    ven.name = "local"
    ven.save
  end
end
