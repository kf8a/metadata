Feature: Data View
  In order to see whether the data is what I'm looking for
  As a potential downloader
  I want to see the metadata and a sample of the data

  Background:
      
  Scenario: Normal user sees which datatables are available
    Given I am in the lter subdomain
      And I am signed in as a normal user
      And a public datatable exists named "First one"
      And a public datatable exists named "Second one"
      And a public datatable exists named "Third one"
    When I go to the datatables page
    Then I should see "First one"
      And I should see "Second one"
      And I should see "Third one"