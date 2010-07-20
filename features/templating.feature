Feature: Template editing
In order to alter the layout of a website
As an admin
I want to edit the layout through the website

Scenario: An admin user creates a template
  Given I am signed up and confirmed as "email@person.com"/"password"
    And I have the "admin" role
   When I sign in as "email@person.com"/"password"
    And I go to new templates
   Then I should see "New"
