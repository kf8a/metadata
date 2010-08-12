Given /^a (.*) website exists$/ do |website|
  Factory.create(:website, :name => website)
end

When(/^I check the "(.+?)" website$/) do |name|
  check(field_by_xpath("//label/a[.=#{name}]"))
end

When(/^I uncheck the "(.+?)" website$/) do |name|
  uncheck(field_by_xpath("//label/a[.=#{name}]"))
end
