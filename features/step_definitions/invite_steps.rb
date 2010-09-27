# Email

Then /^an invite message should be sent to "([^"]*)"$/ do |email|
  invite = Invite.find_by_email(email)
  assert !ActionMailer::Base.deliveries.empty?
  result = ActionMailer::Base.deliveries.any? do |email|
    email.to == [invite.email] &&
    email.subject =~ /Welcome/i &&
    email.body =~ /#{invite.invite_code}/
  end
  assert result
end

Given /^"([^"]*)" is invited to be a "([^"]*)" member$/ do |user, sponsor|
  pending # express the regexp above with the code you wish you had
end

When /^I follow the invite link sent to "([^"]*)"$/ do |user|
  pending # express the regexp above with the code you wish you had
end