Feature: Citation Authors
  In order to more quickly add authors
  As an administrator
  I want to be able to type authors all at once in a box

  Background: No cache
    Given the cache is clear

  Scenario: Typing a full author name in a text box
    Given I am signed in as an administrator
    And   I am on the new citation page
    When  I fill in "Authors" with "Jonathon Jones"
    And   I press "Create"
    Then  I should see "Jones, J."
      And I should see "Download citation"

  Scenario: Typing a full author name in a text box
    Given I am signed in as an administrator
    And   I am on the new citation page
    When  I fill in "Authors" with "Jones, Jonathon David"
    And   I press "Create"
    Then  I should see "Jones, J."
      And I should see "Download citation"

  Scenario: Typing full author names with suffix in a text box
    Given I am signed in as an administrator
    And   I am on the new citation page
    When  I fill in "Authors" with "Martin Luther King, Jr."
    And   I press "Create"
    Then  I should see "King, M. L., Jr."
      And I should see "Download citation"

  Scenario: Multiple author names in a text box
    Given I am signed in as an administrator
    And   I am on the new citation page
    When I fill in "Authors" with:
      """
      Jones, Jonathon David
      Martin Luther King, Jr.
      """
    And I press "Create"
    Then I should see "Jones, J."
      And I should see "M. L. King, Jr."

    When I follow "Edit"
    Then I should see "Jones, Jonathon David"
      And I should see "King, Martin Luther, Jr."
