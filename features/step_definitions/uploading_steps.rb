When /^I attach the SingingSoil test file$/ do
  path_to_test_file = File.join(Rails.root, "test", "data", "SingingSongtestfile.txt")
  attach_file("File", path_to_test_file)
end

Given /^a file "([^"]*)" has been uploaded$/ do |name|
  file_name = File.join(Rails.root, 'test', 'data', name)
  Given %{I am signed in as an administrator}
  When %{I go to the new upload page}
  And %{I fill in "Data Table Title" with "#{name}"}
  attach_file("File", file_name)
  And %{I press "Submit"}
end
