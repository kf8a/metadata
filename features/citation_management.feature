Feature: citations management
  In order to keep the publication database up to date
  As an administrator
  I want to import a bibliography file

  Scenario: Importing a RIS formatted bibliography file
    Given I have signed in with "bob@person.com"/"password"
    And   I have the "admin" role
    And   I am on the new citation page
    When  I attach the file "test/data/bibliography.zip" to "pdf"
    And   I press "Create"
    #Then  I should see "10 records uploaded"

  Scenario: Uploading an RIS formatted file from the command line
