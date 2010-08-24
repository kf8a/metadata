Then /^"([^"]*)" should not have access to the datatable$/ do |email|
  @user = User.find_by_email(email)
  assert !@user.permitted?(@datatable)
end

Given /^"([^"]*)"\/"([^"]*)" owns a datatable named "([^"]*)"$/ do |email, password, name|
  @datatable = Factory.create(:protected_datatable,
    :name     => name, 
    :object   => 'select now()',
    :is_sql   => true)
  @owner = User.find_by_email(email)
  @owner = Factory.create(:email_confirmed_user, :email => email, :password => password) unless @owner
  Factory.create(:ownership, :user => @owner, :datatable => @datatable)
end

Given /^a protected datatable exists named "([^"]*)"$/ do |name|
  @datatable = Factory.create(:protected_datatable,
    :name     => name, 
    :object   => 'select now()',
    :is_sql   => true)
end
