Feature: Editing publication
  In order to fix the publication
  As an admin
  I want to edit a publication

  Scenario: Admin edits a publication
    Given the journal articles publication type exists
      And the following publication exists:
      |year |abstract           |id   |citation         |
      |1984 |"A nice abstract"  |2489 |"A nice citation"|
      And I am signed in as an administrator
    When I go to the publications page
      And I follow "edit" within "div#2489"
    Then I should see "Editing publications"

    When I fill in "Citation" with "An Edited Citation"
      And I press "Update"
    Then I should see "Publication was successfully updated."
      And I should not see "A nice citation"
      And I should see "An Edited Citation"

    When I go to the publications page
    Then I should not see "A nice citation"
      And I should see "An Edited Citation"

Scenario: Admin fails to edit a publication
    Given the journal articles publication type exists
      And the following publication exists:
      |year |abstract           |id   |citation         |
      |1984 |"A nice abstract"  |2489 |"A nice citation"|
      And I am signed in as an administrator
    When I go to the publications page
      And I follow "edit" within "div#2489"
    Then I should see "Editing publications"

    When I fill in "Citation" with ""
      And I press "Update"
    Then I should not see "Publication was successfully updated."

    When I go to the publications page
    Then I should see "A nice citation"
      And I should not see "An Edited Citation"