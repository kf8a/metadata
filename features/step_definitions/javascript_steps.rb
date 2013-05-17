Given /^JS I am signed in as an administrator$/ do
  @user = FactoryGirl :admin_user, :email => "admin@person.com"
  When %{I sign in as "admin@person.com"/"password"}
end

When /^I confirm a js popup on the next step$/ do
  page.evaluate_script("window.alert = function(msg) { return true; }")
  page.evaluate_script("window.confirm = function(msg) { return true; }")
end

When /^I wait for (\d+) seconds$/ do |time|
  sleep time.to_i
end

Then /^(?:|I )should not see hidden text "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, selector|
  its_hidden = page.evaluate_script("jQuery('#{selector}:contains(#{text})').is(':hidden');")
  its_hidden.should be_true
end
