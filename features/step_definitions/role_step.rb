Given /^I am signed in as admin$/ do
  user = Factory :user,
     :email                 => "email@person.com",
     :role                  => 'admin'
  Given %{I sign in as "email@person.com", "password"}
end

Given /^I am signed in as a user$/ do
  user = Factory :user,
     :email                 => "email@person.com"
end
