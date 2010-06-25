Given /^I have an openid provider$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I will be redirected to the the openid provider$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I return$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I will be logged on$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^my email address will be stored$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I am signed up with openid "([^"]*)"$/ do |identity_url|
  user = Factory :user,
     :email                 => "email@person.com",
     :identity_url          => identity_url
end

When /^I sign in as "([^"]*)"$/ do |email|
  When %{I go to the sign in page}
  And %{I fill in "Email" with "#{email}"}
  And %{I press "Sign in"}
end

When /^I sign in with the identity_url "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end
