# Email

Then /^an invite message should be sent to "([^"]*)"$/ do |email|
  invite = Invite.find_by_email(email)
  assert !ActionMailer::Base.deliveries.empty?
  result = ActionMailer::Base.deliveries.any? do |email|
    email.to == [invite.email] &&
    email.subject =~ /Welcome/i
  end
  assert result
end

Given /^"([^"]*)" is invited to be a "([^"]*)" member$/ do |user, sponsor|
  Given %{I am signed in as an administrator}
    And %{A sponsor exists with a name of "glbrc"}
  When %{I go to the new invite page}
   And %{I fill in "Firstname" with "Sam"}
   And %{I fill in "Lastname" with "Brownback"}
   And %{I fill in "Email" with "#{user}"}
   And %{I check "invite_#{sponsor}_member"}
   And %{I press "Create Invite"}
   And %{I go to the invites page}
   And %{I follow "Send Invite"}
   And %{I sign out}
end

When /^I follow the invite link sent to "([^"]*)"$/ do |email|
  invite = Invite.find_by_email(email)
  assert !invite.nil?
  visit new_user_path(:invite_code => invite.invite_code)
end