Given /^a citation with the title "([^"]*)"$/ do |title|
  @citation = Factory.create(:citation, :title => title)
end

When /^I post to citations$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should get an error$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^I should be successful$/ do
  pending # express the regexp above with the code you wish you had
end
