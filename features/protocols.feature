Feature: Protocols should be linked to more than one dataset and show up on one or more websites
  In order to reuse protocols
  As an administrator
  I want to associate protocols with websites
  
  Scenario: Assigning a new protocol to a website
    Given I am in the GLBRC subdomain
    And   "bob@person.com" is an administrator
    When  I sign in as "bob@person.com"/"password"
    And   I go to the "new protocols" page
    And   I fill in "title" with "Earthworm counting"
    And   I select "glbrc" from "websites"
    And   I press "Submit"
    And   I go to the protocols page
    Then  I should see "Earthworm counting"
    When  I am in the LTER subdomain
    And   I go to the protocols page
    Then  I should not see "Earthworm counting"
    
