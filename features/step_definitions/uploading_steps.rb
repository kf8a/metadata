Before do
  host! "lter.dev"
end

When /^I attach the SingingSoil test file$/ do
  path_to_test_file = File.join(Rails.root, "test", "data", "SingingSongtestfile.txt")
  attach_file("file", path_to_test_file, "text")
end
