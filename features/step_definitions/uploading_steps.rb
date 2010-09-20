When /^I attach the SingingSoil test file$/ do
  path_to_test_file = File.join(Rails.root, "test", "data", "SingingSongtestfile.txt")
  attach_file("File", path_to_test_file)
end
