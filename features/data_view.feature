Feature: Data View
  In order to see whether the data is what I'm looking for
  As a potential downloader
  I want to see the metadata and a sample of the data

  Background:
    Given a website exists with a name of "lter"
      And a website exists with a name of "glbrc"
      And I am signed in as a normal user
      And I am in the lter subdomain
      
  Scenario: Seeing which datatables are available
    Given a study exists with a name of "Awesome Study"
      And a public lter datatable exists with a title of "First one"
      And a public lter datatable exists with a title of "Second one"
      And a public lter datatable exists with a title of "Third one"
    When I go to the datatables page
    Then some details should be true
    Then show me the page
    Then I should see "Awesome Study"
    Then I should see "First one"
      And I should see "Second one"
      And I should see "Third one"
      And I should not see "Datatables"

  Scenario: Viewing a public datatable
    Given a public lter datatable exists with species data
    When I go to the datatable page
    Then I should see "Species"
      And I should see "The name of the species"
      And I should see "Genus"
      And I should see "The genus of the species"
