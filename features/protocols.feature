Feature: Protocols should be linked to more than one dataset and show up on one or more websites
  In order to reuse protocols
  As an administrator
  I want to associate protocols with websites
  
  Scenario: Assigning a new protocol to a website
    Given I am in the GLBRC subdomain
    And   a dataset exists with a dataset of "Useful Dataset"
    And   a user exists and is confirmed with an email of "bob@person.com"
    And   "bob@person.com" is an administrator
    When  I sign in as "bob@person.com/password"
    And   I go to the new protocol page
    And   I check "glbrc"
    And   I uncheck "lter"
    And   I fill in "Title" with "Earthworm counting"
    And   I select "Useful Dataset" from "protocol_dataset_id"
    And   I press "Create"
    And   I go to the protocols page
    Then  I should see "Earthworm counting"
  
  Scenario: A protocol which is not assigned to LTER does not show up on LTER
    Given I am in the LTER subdomain
    And   I am signed in as an administrator
    When  I go to the new protocol page
    And   I check "glbrc"
    And   I uncheck "lter"
    And   I fill in "Title" with "Earthworm counting"
    And   I press "Create"
    And   I go to the protocols page
    Then  I should not see "Earthworm counting"
