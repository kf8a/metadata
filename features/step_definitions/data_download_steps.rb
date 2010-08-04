
Given /^I own datatable "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^I have permission to download$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I do not have permission to download$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I will request access to the data$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^a protected datatable exists$/ do
  sponsor = Factory.create(:sponsor, :data_restricted => true)
  dataset = Factory.create(:dataset, :sponsor => sponsor)
  @datatable = Factory.create(:restricted_datatable,
    :name     => 'KBS001', 
    :dataset  => dataset,
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

#Given /^"([^"]*)"\/"([^"]*)" owns the datatable "([^"]*)"$/ do |user, password, datatable|
#  @datatable = Datatable.find_by_name(datatable)
#  @user = User.find_by_email(user)
#  Factory.create(:ownership, :user => @user, :datatable => @datatable)
#end

Given /^"([^"]*)"\/"([^"]*)" does not have permission to download$/ do |arg1, arg2|
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" has given permission$/ do |arg1|
  pending # express the regexp above with the code you wish you had
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

Then /^the file should contain the data$/ do
  pending # express the regexp above with the code you wish you had
end
