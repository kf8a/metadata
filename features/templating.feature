Feature: Template editing
In order to alter the layout of a website
As an admin
I want to edit the layout through the website

Scenario: An admin user creates a template
  Given I am signed in as an administrator
  When I go to the new template page
    And I fill in "Controller" with "Protocols"
    And I fill in "Action" with "Index"
    And I fill in "Layout" with "Test words"
    And I press "Create Template"
  Then I should be on the template page
