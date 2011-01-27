Feature: Creating publication
  In order to share an article
  As an admin
  I want to create a publication

  Scenario: Admin creates an publication
    Given I am signed in as an administrator
    When I go to the publications page
      And I follow "new publication"
    Then I should see "New publication"

    When I fill in "Year" with "2010"
      And I fill in "Citation" with "A quick citation"
      And I fill in "Abstract" with "A quick abstract"
      And I press "Create"
    Then I should see "Publication was successfully created."
      And I should see "A quick abstract"

  Scenario: Admin fails to create a publication
    Given I am signed in as an administrator
    When I go to the publications page
      And I follow "new publication"
    Then I should see "New publication"

    When I fill in "Year" with "2010"
      And I fill in "Citation" with ""
      And I fill in "Abstract" with "A quick abstract"
      And I press "Create"
    Then I should not see "Publication was successfully created."

  Scenario: Admin deletes an publication
    Given the journal articles publication type exists
      And the following publication exists:
      |year |abstract           |id   |citation         |publication_type_id|
      |1984 |"A nice abstract"  |2489 |"A nice citation"|1                  |
      And I am signed in as an administrator
    When I go to the publications page
      And I follow "abstract" within "div#2489"
      And I follow "Destroy"
    Then I should not see "A nice citation"