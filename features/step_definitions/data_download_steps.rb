Given /^I am signed in as "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Given /^I own datatable "([^"]*)"$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end

Then /^I will download a file$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the file will contain the data$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I have permission to download$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should download a file$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^I do not have permission to download$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I will request access to the data$/ do
  pending # express the regexp above with the code you wish you had
end

Given /^a protected datatable$/ do
  datatable = Factory.create( :datatable,
    {:name     => 'KBS001', :sponsor => Factory.create(:restricted => true) } )
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

Given /^a public datatable$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the file should contain the data$/ do
  pending # express the regexp above with the code you wish you had
end

