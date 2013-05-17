Given /^a user exists and is confirmed with an email of "([^"]*)"$/ do |email|
  FactoryGirl :email_confirmed_user, :email => email
end

Given /^I am signed in as a normal user$/ do
  @user = FactoryGirl :email_confirmed_user, :email => "normal@person.com"
  @user.role = "normal"
  When %{I sign in as "normal@person.com/password"}
end

Given /^I am signed in as an administrator$/ do
  @user = User.find_by_email('admin@person.com') || FactoryGirl(:admin_user, :email => "admin@person.com")
  When %{I sign in as "admin@person.com/password"}
end

Given /^I am signed in as an uploader$/ do
  @user = User.find_by_email('uploader@person.com') || FactoryGirl(:email_confirmed_user, :email => "uploader@person.com")
  @user.role = "uploader"
  When %{I sign in as "uploader@person.com/password"}
end

Given /^"([^"]*)" is a "([^"]*)" member$/ do |email, sponsor_name|
  user = User.find_by_email(email)
  sponsor = FactoryGirl :sponsor, :name => sponsor_name
  user.sponsors << sponsor
end

Then /^"([^"]*)" should be a "([^"]*)" member$/ do |email, sponsor_name|
  user = User.find_by_email(email)
  sponsor = Sponsor.find_by_name(sponsor_name)
  assert sponsor.present?
  membership = Membership.find_by_user_id_and_sponsor_id(user, sponsor)
  assert membership.present?
  assert user.memberships.include?(membership)
  assert user.sponsors.include?(sponsor)
end

Given /^I am signed out$/ do
  Given %{I am on the sign out page}
end
