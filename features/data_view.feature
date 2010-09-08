Feature: Data View
  In order to see whether the data is what I'm looking for
  As a potential downloader
  I want to see the metadata and a sample of the data

  Background:
    Given a website exists named "lter"
      And a website exists named "glbrc"
      And I am signed in as a normal user
      And I am in the lter subdomain
      And all caches are cleared
      
  Scenario: Seeing which datatables are available
    Given a public lter datatable exists titled "First one"
      And a public lter datatable exists titled "Second one"
      And a public lter datatable exists titled "Third one"
    When I go to the datatables page
    Then I should see "First one"
      And I should see "Second one"
      And I should see "Third one"

  Scenario: Viewing a public datatable
    Given a public lter datatable exists with species data
    When I go to the datatable page
    Then I should see "Title"
      And I should see "The name of the book"
      And I should see "Length"
      And I should see "How long the book is"
      And I should see "pages"