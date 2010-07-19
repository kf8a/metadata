Feature: Only admins should be able to edit 

Scenario: A admin user wants to edit
  Given I am signed in as admin
  When I go to the edit page
  Then I should see the edit page
  
Scenario: A regular user wants to edit
  Given I am signed in as a user
  When I go to the edit page
  
