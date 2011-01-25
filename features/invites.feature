Feature: Invite users and pre assign them to sponsors
  In order to add users to the appropriate sponsor
  As an admin
  I want to send out invites and pre assign users to sponsors when they sign up
          
  Scenario: An admin creates and sends invite to a glbrc member
    Given I am signed in as an administrator
    When I go to the new invite page
     And I fill in "Firstname" with "Sam"
     And I fill in "Lastname" with "Brownback"
     And I fill in "Email" with "sam@person.com"
     And I check "invite_glbrc_member"
    When I press "Create Invite"
    Then I should see "successfully created"
    When I go to the invites page
     And I follow "Send Invite"
    Then an invite message should be sent to "sam@person.com"
    
    
  Scenario: A glbrc member invitee signs up
    Given "sam@person.com" is invited to be a "glbrc" member
    When I follow the invite link sent to "sam@person.com"
     And I fill in "user_email" with "sam@person.com"
     And I fill in "user_password" with "password"
     And I fill in "user_password_confirmation" with "password"
     And I press "Sign up"
    Then I should see "You are now signed up"
     And "sam@person.com" is a "glbrc" member
