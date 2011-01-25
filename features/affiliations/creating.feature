Feature: Creating affiliation
  In order to assign accurate rights
  As an admin
  I want to create an affiliation

  Scenario: Admin creates an affiliation
    Given I am signed in as an administrator
    When I go to the affiliations page
      And I follow "New affiliation"
    Then I should see "New affiliation"

    When I fill in "Title" with "President"
      And I fill in "Seniority" with "High"
      And I press "Create"
    Then I should see "Affiliation was successfully created."
      And I should see "President"

  Scenario: Admin deletes an affiliation
    Given I am signed in as an administrator
      And the following affiliation exists:
      |title          |Seniority |id   |
      |"El Presidente"|"Supre"   |7331 |

    When I go to the affiliations page
      And I follow "Destroy" within "tr#affiliation_7331"
    Then I should not see "El Presidente"