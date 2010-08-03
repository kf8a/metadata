
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
  sponsor = Factory :sponsor, :data_restricted => true
  dataset = Factory :dataset, :sponsor => sponsor
  @datatable = Factory  :datatable,
    :name     => 'KBS001', 
    :dataset  => dataset,
    :object   => 'select now()',
    :is_sql   => true
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

Given /^"([^"]*)" is an administrator$/ do |user|
  @user = User.find_by_email(user)
  @user.role = "admin"
  @user.save
end

Then /^the file should contain the data$/ do
  pending # express the regexp above with the code you wish you had
end
