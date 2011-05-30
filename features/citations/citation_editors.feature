Feature: Citation Editors
  In order to more quickly add editors
  As an administrator
  I want to be able to type editors all at once in a box

  Background: No cache
    Given the cache is clear

  Scenario: Typing a full editor name in a text box
    Given I am signed in as an administrator
    And   I am on the new citation page
    When  I fill in "Editors" with "Jonathon Jones"
      And I select "Book" from "Type"
    And   I press "Create"
    Then  I should see "J. Jones"
      And I should see "Download citation"

  Scenario: Typing a full editor name in a text box
    Given I am signed in as an administrator
    And   I am on the new citation page
    When  I fill in "Editors" with "Jones, Jonathon David"
    And I select "Book" from "Type"
    And   I press "Create"
    Then  I should see "J. D. Jones"
      And I should see "Download citation"

  Scenario: Typing full editor names with suffix in a text box
    Given I am signed in as an administrator
    And   I am on the new citation page
    When  I fill in "Editors" with "Martin Luther King, Jr."
    And I select "Book" from "Type"
    And   I press "Create"
    Then  I should see "M. L. King, Jr."
      And I should see "Download citation"

  Scenario: Multiple editor names in a text box
    Given I am signed in as an administrator
    And   I am on the new citation page
    When I fill in "Editors" with:
      """
      Jones, Jonathon David
      Martin Luther King, Jr.
      """
    And I select "Book" from "Type"
    And I press "Create"
    Then I should see "J. D. Jones"
      And I should see "M. L. King, Jr."

    When I follow "Edit"
    Then I should see "Jones, Jonathon David"
      And I should see "King, Martin Luther, Jr."
