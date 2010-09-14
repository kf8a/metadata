When(/^I check the "(.+?)" website$/) do |name|
  @website = Website.find_by_name(name)
  check "protocol[website_list][#{@website.id}]"
end

When(/^I uncheck the "(.+?)" website$/) do |name|
  @website = Website.find_by_name(name)
  uncheck "protocol[website_list][#{@website.id}]"
end
