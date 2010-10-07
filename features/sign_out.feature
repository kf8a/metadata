Feature: Sign out
  To protect my account from unauthorized access
  A signed in user
  Should be able to sign out

    Scenario: User signs out
      Given I am in the LTER subdomain
      Given I am signed up and confirmed as "email@person.com"/"password"
      When I sign in as "email@person.com"/"password"
        And I follow the redirect
      Then I should be signed in
      When I sign out
      Then I should be signed out
