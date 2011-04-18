Feature: All the javascripts should work properly
  In order to use the website more dynamically
  As a user
  I want to be able to use javascript

  @javascript
  Scenario: An admin creates and then deletes an abstract
    Given I am signed in as an administrator
      And the local venue type exists
    When I go to the new meeting page
      And I fill in "meeting_title" with "Long Meeting"
      And I press "Create"
      And I go to the meetings page
    Then I should see "Long Meeting"
    When I confirm a js popup on the next step
      And I follow "Trash"
      And I wait for 3 seconds
    Then I should not see hidden text "Long Meeting"