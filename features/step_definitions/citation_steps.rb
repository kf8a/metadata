Given /^a citation with the title "([^"]*)"$/ do |title|
  @citation = Factory.create(:citation, :title => title)
end

Given /^a file "([^"]*)" has been uploaded$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end
