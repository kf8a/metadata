When /^I attach the SingingSoil test file$/ do
  path_to_test_file = File.join(Rails.root, "test", "data", "SingingSongtestfile.txt")
  attach_file("File", path_to_test_file)
end

Given /^a file "([^"]*)" has been uploaded$/ do |name|
  file_name = File.join(Rails.root, 'test', 'data', name)
  Given %{I am signed up and confirmed as "email@person.com"/"password"}
    And %{I have the "admin" role}
   When %{I sign in as "email@person.com"/"password"}
  When %{I go to the new upload page}
  attach_file("File", file_name)
  And %{I press "Submit"}
end
