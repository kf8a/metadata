Feature: Browsing Publications
  In order to see what publications are available
  As a normal user
  I want to see all of the publications

  Scenario: Going to the publication index to see publications
    Given a publication type exists with an id of "1"
      And the following publication exists:
      |year   |abstract         |id   |
      |1984 |"A nice abstract"  |2488 |
      And I am signed in as a normal user
    When I go to the publications page
    Then I should see "1984"

    When I follow "abstract" within "div#2488"
      Then I should see "A nice abstract"