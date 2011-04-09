Feature: Searching Citations
  In order to find a citation
  As a normal user
  I want to search for a word that appears in the citation 

  Background: No cache
    Given the cache is clear
      And a website exists with name: "lter"

  Scenario: Searching with an empty string
    Given a citation exists with pub_year: 1984, abstract: "A nice abstract", id: 2488, title: "Cool citation", website: the website
      And an author exists with citation: the citation
    When I go to the citations page
    And I press "Search all citations"
    Then I should be on the citations page
 
