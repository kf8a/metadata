Feature: Browsing Citations
  In order to see what citations are available
  As a normal user
  I want to see all of the citations

  Background: No cache
    Given the cache is clear
    Then a website should exist with name: "lter"

  Scenario: Going to the citation index to see citations
    Given a citation exists with pub_year: 1984, abstract: "A nice abstract", id: 2488, title: "Cool citation", website: the website
      And an author exists with citation: the citation
      And I am signed in as a normal user

    When I go to the citations page
    Then I should see "1984"
      And I should see "Cool citation"

    When I follow "abstract" within "div#2488"
      Then I should see "A nice abstract"

# This feature has been removed, at least for now
#  Scenario: Browsing by type
#    Given a citation exists with type: "ArticleCitation", pub_year: 1984, abstract: "A nice abstract", title: "Cool citation", website: the website
#      And an author exists with citation: the citation
#      And a citation exists with type: "BookCitation", pub_year: 1981, abstract: "An old abstract", title: "Old citation", website: the website
#      And an author exists with citation: the citation
#      And I am signed in as a normal user
#    Then the website should have 2 citations
#
#    When I go to the citations page
#    Then I should see "1984"
#      And I should see "Cool citation"
#      And I should see "1981"
#      And I should see "Old citation"
#
#    When I select "Article" from "type"
#      And I press "Filter"
#    Then I should see "1984"
#      And I should see "Cool citation"
#      And I should not see "1981"
#      And I should not see "Old citation"
