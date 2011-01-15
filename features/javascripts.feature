Feature: All the javascripts should work properly
  In order to use the website more dynamically
  As a user
  I want to be able to use javascript

  @javascript
  Scenario: An admin creates and then deletes an abstract
    Given I am signed in as an administrator
      And a venue type exists
    When I go to the new meeting page
      And I fill in "meeting_title" with "Long Meeting"
      And I press "Create"
      And I follow "Long Meeting"
      And I follow "Add abstract"
      And I fill in "abstract_title" with "An Awesome Abstract"
      And I fill in "abstract_authors" with "Awesome Guy and Awesome Gal"
      And I fill in "abstract_abstract" with "A testable abstract"
      And I press "Create"
    Then I should see "Awesome Guy and Awesome Gal An Awesome Abstract Edit"
    When I go to the meetings page
      And I follow "Long Meeting"
    Then I should see "Awesome Guy and Awesome Gal"

    When I confirm a js popup on the next step
    When I follow "Trash"
      And I wait for 5 seconds
    Then I should not see hidden text "Awesome Guy and Awesome Gal"
    When I go to the meetings page
      And I follow "Long Meeting"
    Then I should not see "Awesome Guy and Awesome Gal"
