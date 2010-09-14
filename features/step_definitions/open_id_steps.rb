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
