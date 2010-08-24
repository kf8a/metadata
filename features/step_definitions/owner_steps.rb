Then /^"([^"]*)" should not own the datatable "([^"]*)"$/ do |email, name|
  user = User.find_by_email(email)
  user = Factory.create(:email_confirmed_user, :email => email) unless user
  datatable = Datatable.find_by_name(name)
  assert !user.owns?(@datatable)
end

Then /^"([^"]*)" should own the datatable "([^"]*)"$/ do |email, name|
  user = User.find_by_email(email)
  datatable = Datatable.find_by_name(name)
  assert user.owns?(@datatable)
end
