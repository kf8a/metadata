Given /^a protected datatable exists$/ do
  @datatable = Factory.create(:protected_datatable)
end

Given /^a public datatable exists$/ do
  @datatable = Factory.create(:datatable)
end

Given /^"([^"]*)"\/"([^"]*)" owns the datatable$/ do |owner, password|
  @owner = User.find_by_email(owner)
  @owner = Factory.create(:email_confirmed_user, :email => owner, :password => password) unless @owner
  Factory.create(:ownership, :user => @owner, :datatable => @datatable)
end

Given /^"([^"]*)" has permission to download the datatable$/ do |user|
  @user = User.find_by_email(user)
  @user = Factory.create(:email_confirmed_user, :email => user) unless @user
  @owner = Factory.create(:email_confirmed_user)
  ownership = Ownership.find_by_user_id_and_datatable_id(@owner.id, @datatable.id)
  Factory.create(:ownership, :user => @owner, :datatable => @datatable) unless ownership
  Factory.create(:permission, :user => @user, :datatable => @datatable, :owner => @owner)
end

Given /^"([^"]*)" does not have permission to download the datatable$/ do |user|
  @user = User.find_by_email(user)
  @user = Factory.create(:email_confirmed_user, :email => user) unless @user
  @owner = Factory.create(:email_confirmed_user) unless @owner
  ownership = Ownership.find_by_user_id_and_datatable_id(@owner.id, @datatable.id)
  Factory.create(:ownership, :user => @owner, :datatable => @datatable) unless ownership
  assert_nil Permission.find_by_user_id(@user)
end

Given /^"([^"]*)" has given "([^"]*)" permission$/ do |owner, user|
  @user = User.find_by_email(user)
  @owner = User.find_by_email(owner)
  @user = Factory.create(:email_confirmed_user, :email => user) unless @user
  @owner = Factory.create(:email_confirmed_user) unless @owner
  ownership = Ownership.find_by_user_id_and_datatable_id(@owner, @datatable)
  Factory.create(:ownership, :user => @owner, :datatable => @datatable) unless ownership
  Factory.create(:permission, :user => @user, :datatable => @datatable, :owner => @owner)
end

Given /^"([^"]*)" has not given "([^"]*)" permission$/ do |owner, user|
  @user = User.find_by_email(user)
  @owner = User.find_by_email(owner)
  @user = Factory.create(:email_confirmed_user, :email => user) unless @user
  @owner = Factory.create(:email_confirmed_user) unless @owner
  ownership = Ownership.find_by_user_id_and_datatable_id(@owner, @datatable)
  Factory.create(:ownership, :user => @owner, :datatable => @datatable) unless ownership
  permission = Permission.find_by_user_id_and_owner_id(@user, @owner)
  permission.destroy if permission
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

Given /^all caches are cleared$/ do
  @controller.expire_fragment(%r{.*})
end
