Given /^I have the "([^"]*)" role$/ do |role|
  user = User.first
  user.role = role
  user.save   #need to save so that it can be found later
end

Then /^I should have the "([^"]*)" role$/ do |role|
  assert controller.current_user.role == role
end
