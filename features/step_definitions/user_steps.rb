Given /^a user exists and is confirmed with an email of "([^"]*)"$/ do |email|
  Factory :email_confirmed_user, :email => email
end

Given /^I am signed in as a normal user$/ do
  @user = Factory :email_confirmed_user, :email => "normal@person.com"
  @user.role = "normal"
  When %{I sign in as "normal@person.com"/"password"}
end

Given /^I am signed in as an administrator$/ do
  @user = Factory :admin_user, :email => "admin@person.com"
  When %{I sign in as "admin@person.com"/"password"}
end

Given /^I am signed in as an uploader$/ do
  @user = Factory :email_confirmed_user, :email => "uploader@person.com"
  @user.role = "uploader"
  When %{I sign in as "uploader@person.com"/"password"}
end

Given /^"([^"]*)" is a "([^"]*)" member$/ do |email, sponsor_name|
  user = User.find_by_email(email)
  sponsor = Factory :sponsor, :name => sponsor_name
  user.sponsors << sponsor
end
