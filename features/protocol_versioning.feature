Feature: Protocols should exists in several versions
  In order to understand how the data was collected
  As a user
  I want to see older version of the protocol

  Background:

  Scenario: a protocol is updated to a new version
    Given I am signed in as an administrator
    And a protocol exists
    And I go to the protocols edit page
    And I change the title to 'new protocol'
    And I check the 'consider this a new version' checkbox
    When I hit 'update'
    And I go to the protocol page
    Then I should see the 'new protocol'
    And I should see a link to the previous protocol
