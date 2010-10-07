Feature: Sign up
  In order to get access to protected sections of the site
  A user
  Should be able to sign up

    Scenario: User signs up with invalid data
      Given I am in the LTER subdomain
      When session is cleared
      And I go to the sign up page
      And I fill in "Email" with "invalidemail"
      And I fill in "Password" with "password"
      And I fill in "Confirm password" with ""
      And I press "Sign up"
      Then I should see "is invalid"
      And I should see "doesn't match confirmation"

    Scenario: User signs up with valid data
      Given I am in the LTER subdomain
      When session is cleared
      And I go to the sign up page
      And I fill in "Email" with "email@person.com"
      And I fill in "Password" with "password"
      And I fill in "Confirm password" with "password"
      And I press "Sign up"
      And I follow the redirect
      Then I should see "instructions for confirming"
      And a confirmation message should be sent to "email@person.com"

    Scenario: User confirms his account
      Given I am in the LTER subdomain
      Given I signed up with "email@person.com"/"password"
      When session is cleared
      And I follow the confirmation link sent to "email@person.com"
      And I follow the redirect
      Then I should see "Confirmed email and signed in"

    Scenario: Signed in user clicks confirmation link again
      Given I am in the LTER subdomain
      Given I signed up with "email@person.com"/"password"
      When session is cleared
      And I follow the confirmation link sent to "email@person.com"
      And I follow the redirect
      Then I should see "Confirmed email and signed in"
      When I follow the confirmation link sent to "email@person.com"
        And I follow the redirect
      Then I should see "Confirmed email and signed in"

    Scenario: Signed out user clicks confirmation link again
      Given I am in the LTER subdomain
      Given I signed up with "email@person.com"/"password"
      When session is cleared
      And I follow the confirmation link sent to "email@person.com"
      And I follow the redirect
      Then I should see "Confirmed email and signed in"
      When I sign out
        And I follow the confirmation link sent to "email@person.com"
        And I follow the redirect
      Then I should see "Already confirmed email. Please sign in."
      
