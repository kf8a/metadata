Feature: Only admins should be able to edit 

Scenario: A signed in user wants to edit
  Given I have signed in with "email@person.com"/"password"
    And a public datatable
  When  I go to the datatable page
  And  I should not see "edit"
  
Scenario: A signed in user goes to the edit page
  Given I have signed in with "email@person.com"/"password"
    And a public datatable
  When  I go to the datatable edit page
  Then  I should be on the sign_in page
  
Scenario: An anonymous user wants to edit
  Given a public datatable
  When  I go to the datatable page
  Then  I should not see "edit"
   
Scenario: An admin user wants to edit
  Given I am signed in as admin
    And a public datatable
    And I am in the LTER subdomain
  When  I go to the datatables page
  Then  I should see "edit"
