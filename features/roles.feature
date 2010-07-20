Feature: Only admins should be able to edit 
    
Scenario: A signed in user wants to edit
  Given I am signed up and confirmed as "email@person.com"/"password"
  And   a public datatable exists
  When  I sign in as "email@person.com"/"password"
  Then  I should be signed in
  When  I go to the datatable page
  And  I should not see "edit"
  
Scenario: A signed in user goes to the edit page
  Given I have signed in with "email@person.com"/"password"
    And a public datatable exists
  When  I go to the datatable edit page
  Then  I should be on the sign_in page
  
Scenario: An anonymous user wants to edit
  Given a public datatable exists
  When  I go to the datatable page
  Then  I should not see "edit"
  
Scenario: A admin user wants to edit
  Given I am signed up and confirmed as "email@person.com"/"password"
    And I have the "admin" role
    And a public datatable exists
  When  I sign in as "email@person.com"/"password"
  Then  I should be signed in
   And  I should have the "admin" role
  When  I go to the datatable page
  Then  I should see "Edit"
