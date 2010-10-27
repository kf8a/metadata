Given /^I am in the (.*) subdomain$/ do |subdomain|
  subdomain = subdomain.downcase
  Capybara.default_host = "#{subdomain}.localhost"
  Capybara.app_host = "http://#{subdomain}.localhost:3000"
end

When /^I follow the redirect$/ do
  follow_redirect! if redirect?
end