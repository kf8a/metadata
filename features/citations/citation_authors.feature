Feature: Citation Authors
  In order to more quickly add authors
  As an administrator
  I want to be able to type authors all at once in a box

  Background: No cache
    Given the cache is clear

  Scenario: Typing full author names in a text box
    Given I am signed in as an administrator
    And   I am on the new citation page
    When  I fill in "Authors" with "Jonathon Jones"
    And   I press "Create"
    Then  I should see "Jonathon Jones"
      And I should see "Download citation"
