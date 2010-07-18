Given /^I am in the (.*) subdomain$/ do |subdomain|
  subdomain = subdomain.downcase
  path = "http://#{subdomain}.localhost:3000"
  visit path
end
