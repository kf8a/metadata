Feature: Only admins should be able to edit 

Scenario: A signed in user wants to edit
  Given I am signed in as a normal user
    And a public datatable exists
  When I go to the datatable page
  Then  I should not see "Edit"
  
Scenario: A signed in user goes to the edit page
  Given I am signed in as a normal user
    And a public datatable exists
  When  I go to the datatable edit page
  Then  I should be on the sign_in page
  
Scenario: An anonymous user wants to edit
  Given a public datatable exists
  When  I go to the datatable page
  Then  I should not see "Edit"
  
Scenario: An admin user wants to edit
  Given I am signed in as an administrator
    And a public datatable exists
  When  I go to the datatable page
  Then  I should see "Edit"
