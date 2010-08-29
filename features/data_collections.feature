Feature: Data Collections
  In order to find the data that I'm looking for
  As a potential downloader
  I want to be able to browse and search the data for some datatables

  Background:
    Given a website exists named "lter"
      And a website exists named "glbrc"
      And I am signed in as a normal user
      And I am in the lter subdomain
      And all caches are cleared

  Scenario: Seeing which datatables are available as collections
    Given a public lter datatable exists titled "First one"
      And the datatable has a collection
      And a public lter datatable exists titled "Second one"
      And the datatable has a collection
      And a public lter datatable exists titled "Third one"
      And the datatable has a collection
    When I go to the collections page
    Then I should see "First one"
      And I should see "Second one"
      And I should see "Third one"

  Scenario: Viewing a public datatable's collection
    Given a public lter datatable exists with book data
      And the datatable has a collection
    When I go to the collection page
    Then I should see "sample date"
      And I should see "Title: Language, Truth, and Logic"
      And I should see "Author: Ayer, Alfred Jules"
      And I should see "LOC Call Number: B53 .A9 1952"
      And I should see "LOC Control Number: 52000860"
      And I should see "Completed Reading?: False"

      And I should see "Title: The economist's view of the world"
      And I should see "Author: Rhoads, Steven E."
      And I should see "LOC Call Number: HB171 .R43 1985"
      And I should see "LOC Control Number: 84014997"
      And I should see "Completed Reading?: True"
