Feature: citations management
  In order to keep the publication database up to date
  As an administrator
  I want to import a bibliography file

  Background: No cache
    Given the cache is clear
      And a website exists with name: "lter"

  Scenario: Importing a RIS formatted bibliography file
    Given I am signed in as an administrator
    And   I am on the new citation page
    When  I attach the file "test/data/bibliography.zip" to "Pdf"
    And   I press "Create"
    #Then  I should see "10 records uploaded"

  Scenario: Uploading an RIS formatted file from the command line
