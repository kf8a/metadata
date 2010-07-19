Feature: Template editing
In order to alter the layout of a website
As an admin
I want to edit the layout through the website

Scenario: An admin user creates a template
Given I am signed in as an admin
When I go to templates/new
Then I should see 'New Template'
