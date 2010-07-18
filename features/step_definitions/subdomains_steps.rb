Given /^I am in the (.*) subdomain$/ do |subdomain|
  subdomain = subdomain.downcase
  visit 'http://#{subdomain}.localhost:3000'
end
