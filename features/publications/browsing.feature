Feature: Browsing Publications
  In order to see what publications are available
  As a normal user
  I want to see all of the publications

  Scenario: Going to the publication index to see publications
    Given the journal articles publication type exists
      And the following publication exists:
      |year   |abstract         |id   |citation|
      |1984 |"A nice abstract"  |2488 |"Cool citation"|
      And I am signed in as a normal user
    When I go to the publications page
    Then I should see "1984"
      And I should see "Cool citation"

    When I follow "abstract" within "div#2488"
      Then I should see "A nice abstract"

  Scenario: Searching the publications index
    Given the journal articles publication type exists
      And the following publications exist:
      |year   |abstract         |id   |citation|
      |1984 |"A nice abstract"  |2488 |"Cool citation"|
      |1981 |"An old abstract"  |2489 |"Old citation"|
      And I am signed in as a normal user
    When I go to the publications page
    Then I should see "1984"
      And I should see "Cool citation"
      And I should see "1981"
      And I should see "Old citation"

    When I fill in "word" with "Old citation"
      And I press "Search"
    Then I should see "1981"
      And I should see "Old citation"
      And I should not see "1984"
      And I should not see "Cool citation"