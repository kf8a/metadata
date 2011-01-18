When /^I confirm a js popup on the next step$/ do
  #page.evaluate_script("window.alert = function(msg) { return true; }")
  #page.evaluate_script("window.confirm = function(msg) { return true; }")
end

When /^I wait for (\d+) seconds$/ do |time|
  sleep time.to_i
end