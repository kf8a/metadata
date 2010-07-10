Given /^I am signed in$/ do
  pending # express the regexp above with the code you wish you had
end

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

Given /^a protected datatable$/ do
  sponsor = Factory :sponsor, :data_restricted => true
  dataset = Factory :dataset, :sponsor => sponsor
  @datatable = Factory  :datatable,
    :name     => 'KBS001', 
    :dataset  => dataset,
    :object   => 'select now()',
    :is_sql   => true
end


Given /^a public datatable$/ do
  @datatable = Factory :datatable,
    :id       => 1,
    :name     => 'KBS001',
    :dataset  => Factory.create(:dataset),
    :object   => 'select now()',
    :is_sql   => true
end


Given /^the datatable is owned by "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" has given permission$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^"([^"]*)" has not given permission$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^the file should contain the data$/ do
  pending # express the regexp above with the code you wish you had
end
