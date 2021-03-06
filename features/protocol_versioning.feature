Feature: Protocols should exists in several versions
  In order to understand how the data was collected
  As a user
  I want to see older version of the protocol

  Scenario: a protocol is updated to a new version
    Given I am signed in as an administrator
    And a protocol exists with title: "old protocol"
    And I go to the protocol's edit page
    And I fill in "Title" with "new protocol"
    And I check "glbrc"
    And I check "new_version"
    When I press "Update"
    Then I should see "new protocol"
    And I should see "old protocol"
