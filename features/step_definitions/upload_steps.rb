Given /^the following uploads:$/ do |uploads|
  Upload.create!(uploads.hashes)
end

Given /^I am a logged_in$/ do
  pending # express the regexp above with the code you wish you had
end

When /^I delete the (\d+)(?:st|nd|rd|th) upload$/ do |pos|
  visit uploads_path
  within("table tr:nth-child(#{pos.to_i+1})") do
    click_link "Destroy"
  end
end

Then /^I should see the following uploads:$/ do |expected_uploads_table|
  expected_uploads_table.diff!(tableish('table tr', 'td,th'))
end
