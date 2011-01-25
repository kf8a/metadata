Feature: Editing affiliation
  In order to fix the affiliation
  As an admin
  I want to edit an affiliation

  Scenario: Admin edits an affiliation
    Given I am signed in as an administrator
      And the following affiliation exists:
      |title          |Seniority |id   |
      |"El Presidente"|"Supre"   |7331 |

    When I go to the affiliations page
      And I follow "Edit" within "tr#affiliation_7331"
    Then I should see "Editing affiliation"

    When I fill in "Title" with "An Edited Affiliation"
      And I press "Update"
    Then I should see "Affiliation was successfully updated."
      And I should not see "El Presidente"
      And I should see "An Edited Affiliation"

    When I go to the affiliations page
    Then I should not see "El Presidente"
      And I should see "An Edited Affiliation"