Feature: Going back accurately
  In order to freely go back in the broswer
  As a User
  I want to stay logged in/out when I go back

  @javascript
  Scenario: A user visits datatable index, signs out, goes back
    Given I am in the glbrc subdomain
      And I am signed in as a normal user
      And I am on the datatables page
    Then I should see "Sign Out"

    When I follow "Sign Out"
      And I go back
    Then I should see "Sign In"
