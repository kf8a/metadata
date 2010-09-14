When /^I attach the SingingSoil test file$/ do
  path_to_test_file = File.join(Rails.root, "test", "data", "SingingSongtestfile.txt")
  attach_file("file", path_to_test_file, "text")
end

Given /^a file "([^"]*)" has been uploaded$/ do |arg1|
  pending # express the regexp above with the code you wish you had
end
