Feature: Browsing Citations
  In order to see what citations are available
  As a normal user
  I want to see all of the citations

  Background: No cache
    Given the cache is clear

  Scenario: Going to the citation index to see citations
    Given the following citation exists:
      |pub_year|abstract         |id   |title          |
      |1984    |"A nice abstract"|2488 |"Cool citation"|
      And I am signed in as a normal user
    When I go to the citations page
    Then I should see "1984"
      And I should see "Cool citation"

    When I follow "abstract" within "div#2488"
      Then I should see "A nice abstract"

  Scenario: Searching the citations index
    Given the following citations exist:
      |pub_year|abstract         |id   |title          |
      |1984    |"A nice abstract"|2488 |"Cool citation"|
      |1981    |"An old abstract"|2489 |"Old citation" |
      And I am signed in as a normal user
    When I go to the citations page
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

  Scenario: Browsing by type
    Given the following citations exist:
      |pub_year|abstract         |id   |title          |type|
      |1984    |"A nice abstract"|2488 |"Cool citation"|ArticleCitation|
      |1981    |"An old abstract"|2489 |"Old citation" |BookCitation|
      And I am signed in as a normal user
    When I go to the citations page
    Then I should see "1984"
      And I should see "Cool citation"
      And I should see "1981"
      And I should see "Old citation"

    When I select "Article" from "type"
      And I press "Search"
    Then I should see "1984"
      And I should see "Cool citation"
      And I should not see "1981"
      And I should not see "Old citation"
