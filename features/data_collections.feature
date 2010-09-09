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
    Given a public lter datatable exists with species data
      And the datatable has a collection
    When I go to the collection page
    Then I should see "Species: P. leo"
      And I should see "Genus: Panthera"
      And I should see "Family: Felidae"
      And I should see "Common Name: Lion"

      And I should see "Species: P. tigris"
      And I should see "Genus: Panthera"
      And I should see "Family: Felidae"
      And I should see "Common Name: Tiger"

      And I should see "Species: U. americanus"
      And I should see "Genus: Ursus"
      And I should see "Family: Ursidae"
      And I should see "Common Name: American Black Bear"

  Scenario: Searching a public datatable's collection
    Given a public lter datatable exists with species data
      And the datatable has a collection
    When I go to the collection page
      And I press "Show customization forms"
      And I select "Family" from "limitby"
      And I press "Customize"
      And I fill in "contains" with "Felidae"
      And I press "Customize"
    Then I should see "Species: P. leo"
      And I should see "Species: P. tigris"
      And I should not see "Species: U. americanus"

  Scenario: Searching a public datatable's collection using parameters
    Given a public lter datatable exists with species data
      And the datatable has a collection
    When I go to the collection page
      And I press "Show customization forms"
      And I select "Common Name" from "limitby"
      And I press "Customize"
      And I select "American Black Bear" from "limit1"
      And I select "Lion" from "limit2"
      And I press "Customize"
    Then I should see "Common Name: American Black Bear"
      And I should see "Common Name: Lion"
      And I should not see "Common Name: Tiger"