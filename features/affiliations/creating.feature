Feature: Creating abstract
  In order to provide a quick overview
  As an admin
  I want to create an abstract

  Scenario: Admin creates an affiliation
    Given an admin user exists with an email of "admin@person.com"
    When I sign in as "admin@person.com"/"password"
      And I go to the affiliations page
      And I follow "New affiliation"
    Then I should see "New affiliation"

    When I fill in "Title" with "President"
      And I fill in "Seniority" with "High"
      And I press "Create"
    Then I should see "Affiliation was successfully created."
      And I should see "President"

  Scenario: Admin deletes an affiliation
    Given an admin user exists with an email of "admin@person.com"
      And the following affiliation exists:
      |title          |Seniority |id   |
      |"El Presidente"|"Supre"   |7331 |

    When I sign in as "admin@person.com"/"password"
      And I go to the affiliations page
      And I follow "Destroy" within "tr#affiliation_7331"
    Then I should not see "El Presidente"