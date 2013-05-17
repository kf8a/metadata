Given /^"([^"]*)" owns the datatable named "([^"]*)"$/ do |email, name|
  owner = User.find_by_email(email)
  datatable = Datatable.find_by_name(name)
  FactoryGirl.create(:ownership, :user => owner, :datatable => datatable)
end

Given /^"([^"]*)" owns the datatable$/ do |email|
  owner = User.find_by_email(email)
  datatable = Datatable.last
  FactoryGirl.create(:ownership, :user => owner, :datatable => datatable)
end

Given /^"([^"]*)" does not own the datatable$/ do |email|
  owner = User.find_by_email(email)
  datatable = Datatable.last
  ownership = Ownership.find_by_user_id_and_datatable_id(owner, datatable)
  ownership.try(:delete)
end

Then /^"([^"]*)" should own the datatable "([^"]*)"$/ do |email, name|
  user = User.find_by_email(email)
  datatable = Datatable.find_by_name(name)
  assert user.owns?(datatable)
end

Then /^"([^"]*)" should not own the datatable "([^"]*)"$/ do |email, name|
  user = User.find_by_email(email)
  user = FactoryGirl.create(:email_confirmed_user, :email => email) unless user
  datatable = Datatable.find_by_name(name)
  assert !user.owns?(datatable)
end
