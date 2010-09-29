Feature: Creating publication
  In order to share an article
  As an admin
  I want to create a publication

  Scenario: Admin creates an publication
    Given a publication type exists with an id of "1"
      And an admin user exists with an email of "admin@person.com"
    When I sign in as "admin@person.com"/"password"
      And I go to the publications page
      And I follow "new publication"
    Then I should see "New publication"

    When I fill in "Year" with "2010"
      And I fill in "Citation" with "A quick citation"
      And I fill in "Abstract" with "A quick abstract"
      And I press "Create"
    Then I should see "Publication was successfully created."
      And I should see "A quick abstract"

  Scenario: Admin fails to create a publication
    Given a publication type exists with an id of "1"
      And an admin user exists with an email of "admin@person.com"
    When I sign in as "admin@person.com"/"password"
      And I go to the publications page
      And I follow "new publication"
    Then I should see "New publication"

    When I fill in "Year" with "2010"
      And I fill in "Citation" with ""
      And I fill in "Abstract" with "A quick abstract"
      And I press "Create"
    Then I should not see "Publication was successfully created."

  Scenario: Admin deletes an publication
    Given a publication type exists with an id of "1"
      And the following publication exists:
      |year |abstract           |id   |citation         |
      |1984 |"A nice abstract"  |2489 |"A nice citation"|
      And an admin user exists with an email of "admin@person.com"
    When I sign in as "admin@person.com"/"password"
      And I go to the publications page
      And I follow "abstract" within "div#2489"
      And I follow "Destroy"
    Then I should not see "A nice citation"