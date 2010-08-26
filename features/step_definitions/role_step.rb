Given /^I have the "([^"]*)" role$/ do |role|
  user = User.first
  user.role = role
  user.save   #need to save so that it can be found later
end

Given /^"([^"]*)" is an administrator$/ do |email|
  @user = User.find_by_email(email)
  @user.role = "admin"
  @user.save
end

Given /^"([^"]*)" is not an administrator$/ do |email|
  @user = User.find_by_email(email)
  @user.role = "normal"
  @user.save
end

Then /^I should have the "([^"]*)" role$/ do |role|
  assert_equal controller.current_user.role, role
end

Then /^I should not have the "([^"]*)" role$/ do |role|
  assert_not_equal controller.current_user.role, role
end
