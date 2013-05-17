Given /^I am signed up with openid "([^"]*)"$/ do |identity_url|
  user = FactoryGirl :user,
     :email                 => "email@person.com",
     :identity_url          => identity_url
end
