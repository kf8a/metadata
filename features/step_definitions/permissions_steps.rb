Given /^"([^"]*)" has permission to download the datatable$/ do |email|
  @user = User.find_by_email(email)
  @owner = Factory.create(:email_confirmed_user)
  datatable = Datatable.last
  Factory.create(:ownership, :user => @owner, :datatable => datatable)
  Factory.create(:permission, :user => @user, :datatable => datatable, :owner => @owner)
end

Given /^"([^"]*)" does not have permission to download the datatable$/ do |email|
  @user = User.find_by_email(email)
  assert_nil Permission.find_by_user_id_and_datatable_id(@user, @datatable)
end

Given /^"([^"]*)" has given "([^"]*)" permission$/ do |owner, user|
  @user = User.find_by_email(user)
  @owner = User.find_by_email(owner)
  Factory.create(:permission, :user => @user, :datatable => Datatable.last, :owner => @owner)
  assert Permission.find_by_user_id_and_owner_id(@user, @owner)
end

Given /^"([^"]*)" has not given "([^"]*)" permission$/ do |owner, user|
  @user = User.find_by_email(user)
  @owner = User.find_by_email(owner)
  permission = Permission.find_by_user_id_and_owner_id(@user, @owner)
  permission.destroy if permission
end

Then /^"([^"]*)" should not have access to the datatable$/ do |email|
  @user = User.find_by_email(email)
  assert !@user.permitted?(Datatable.last)
end