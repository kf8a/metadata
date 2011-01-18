Given /^I am in the (.*) subdomain$/ do |subdomain|
  subdomain = subdomain.downcase
  Capybara.default_host = "#{subdomain}.localhost"
  switch_session(subdomain)
  visit("http://#{subdomain}.localhost")
end

When /^I follow the redirect$/ do
  follow_redirect! if redirect?
end