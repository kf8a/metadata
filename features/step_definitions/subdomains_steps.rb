Given /^I am in the (.*) subdomain$/ do |subdomain|
  subdomain = subdomain.downcase
  path = "http://#{subdomain}.localhost:3000"
  visit path
end

Given /^a website exists named "([^"]*)"$/ do |name|
  Factory.create(:website, :name => name)
end


When /^I follow the redirect$/ do
  follow_redirect! if redirect?
end
