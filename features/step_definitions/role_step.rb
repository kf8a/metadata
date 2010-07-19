Given /^I am signed in as admin$/ do
  user = Factory :user,
     :email                 => "email@person.com",
     :role                  => 'admin'
end

Given /^I am signed in as a user$/ do
  user = Factory :user,
     :email                 => "email@person.com"
end
