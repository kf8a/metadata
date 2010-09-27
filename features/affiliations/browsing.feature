Feature: Browsing Affiliation
  In order to see what affiliations are available
  As a normal user
  I want to see all of the affiliations

  Scenario: Going to the affiliation index to see affiliations
    Given the following affiliation exists:
    |title    |id   |
    |Tech Guy |1337 |
      And I am signed in as a normal user
    When I go to the affiliations page
    Then I should see "Tech Guy"

    When I follow "Show" within "tr#affiliation_1337"
    Then I should see "Tech Guy"
      And I should not see "Edit"
      And I should see "Back"