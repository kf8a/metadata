# Database

Given /^no user exists with an email of "(.*)"$/ do |email|
  assert_nil User.find_by_email(email)
end

Given /^I signed up with "(.*)"\/"(.*)"$/ do |email, password|
  user = Factory :user,
    :email                 => email,
    :password              => password,
    :password_confirmation => password
end

Given /^I am signed up and confirmed as "(.*)"\/"(.*)"$/ do |email, password|
  user = Factory :email_confirmed_user,
    :email                 => email,
    :password              => password,
    :password_confirmation => password
end

#Given /^a user exists with an email of "(.*)"$/ do |email|
#  user = Factory :user,
#    :email                 => email
#end

Given /^a user exists and is confirmed with an email of "([^"]*)"$/ do |email|
  user = Factory :email_confirmed_user,
    :email                 => email
end

Given /^I am signed in as a normal user$/ do
  @user = Factory :email_confirmed_user, :email => "normal@person.com"
  @user.role = "normal"
  When %{I sign in as "normal@person.com"/"password"}
end