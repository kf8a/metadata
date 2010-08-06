Given /^a protected datatable exists$/ do
  @datatable = Factory.create(:protected_datatable,
    :name     => 'KBS001', 
    :object   => 'select now()',
    :is_sql   => true)
end


Given /^a public datatable exists$/ do
  @datatable = Factory :datatable,
    :id       => 1,
    :name     => 'KBS001',
    :dataset  => Factory.create(:dataset),
    :object   => 'select now()',
    :is_sql   => true
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
  Factory.create(:ownership, :user => @owner, :datatable => @datatable)
  Factory.create(:permission, :user => @user, :datatable => @datatable, :owner => @owner)
end

Given /^"([^"]*)" does not have permission to download the datatable$/ do |user|
  @user = User.find_by_email(user)
  @user = Factory.create(:email_confirmed_user, :email => user) unless @user
  @owner = Factory.create(:email_confirmed_user) unless @owner
  Factory.create(:ownership, :user => @owner, :datatable => @datatable)
  assert_nil Permission.find_by_user_id(@user)
end

Given /^"([^"]*)" has given "([^"]*)" permission$/ do |owner, user|
  @user = User.find_by_email(user)
  @owner = User.find_by_email(owner)
  Factory.create(:permission, :user => @user, :datatable => @datatable, :owner => @owner)
end

Given /^"([^"]*)" has not given "([^"]*)" permission$/ do |owner, user|
  @user = User.find_by_email(user)
  @owner = User.find_by_email(owner)
  assert_nil Permission.find_by_user_id_and_owner_id(@user, @owner)
end

Given /^"([^"]*)" is an administrator$/ do |email|
  @user = User.find_by_email(email)
  if @user
    @user.email_confirmed = true
    @user.role = "admin"
    @user.save
  else
    @user = Factory.create(:admin_user, :email => email, :email_confirmed => true)
  end
end

Given /^"([^"]*)" is not an administrator$/ do |email|
  @user = User.find_by_email(email)
  if @user
    @user.email_confirmed = true
    @user.role = "normal"
    @user.save
  else
    @user = Factory.create(:user, :email => email, :email_confirmed => true, :role => "normal")
  end
end

Given /^all caches are cleared$/ do
  @controller.expire_fragment(%r{.*})
end

Then /^the file should contain the data$/ do
  pending # express the regexp above with the code you wish you had
end
