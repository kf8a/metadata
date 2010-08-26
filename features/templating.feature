Feature: Template editing
In order to alter the layout of a website
As an admin
I want to edit the layout through the website

Scenario: An admin user creates a template
  Given a user exists and is confirmed with an email of "bob@person.com"
    And "bob@person.com" is an administrator
  When  I sign in as "bob@person.com"/"password"
    And I go to the new template page
  Then I should be on the new template page
  Then I should see "Layout*"
  
  When I fill in "Controller*" with "Protocols"
    And I fill in "Action*" with "Index"
    And I fill in "Layout*" with "Test words"
    And I press "Create Template"  
