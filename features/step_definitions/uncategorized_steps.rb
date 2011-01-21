Given /^the cache is clear$/ do
  Rails.cache.clear
end

When /^I go back$/ do
  page.evaluate_script('window.history.back()')
end

