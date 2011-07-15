Then /^I should get a response with status (\d+)$/ do |status|
  assert_equal status.to_i, page.driver.status_code
end
