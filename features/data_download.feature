
Feature: Download data
  In order to get data to analyze
  As a user
  I want to download datatables

Scenario: The data owner downloads a datatable
  Given I am signed in as "email@person.com"
    And I own datatable "KBS001"
  When  I go to the datatable page
    And I press "download"
  Then  I will download a file 
    And the file will contain the data

Scenario: An authorized user downloads a datatable
  Given I am signed in as "email@person.com"
    And I have permission to download
  When  I go to the datatable page 
    And I press "download"
  Then  I should download a file
    And the file will contain the data

Scenario: A user requests access to a datatable
  Given I am signed in as "email@person.com"
    And I do not have permission to download 
  When  I go to the datatable page
  Then  I should see "request data"
    And I should not see "download"
  When  I press "request data"
  Then  I will request access to the data
  
Scenario: An anonymous user looks at a protected datatable 
  Given a protected datatable
  When  I go to the datatable page
  Then  I should not see "download"
    And I should not see "request data"
    And I should see "sign in"
    And I should see "sign up"
    
Scenario: A user has received partial permission to download data
  Given I am signed in as "email@person.com"
    And the datatable is owned by "bob and alice"
    And "alice" has given permission
    And "bob" has not given permission
  When  I go to the datatable page
  Then  I should see "request data"
    And I should not see "download"
    And I should see "bob needs to give you permission"
    And I should see "alice has given you permission"

Scenario: An anonymous user looks at a public datatable
  Given a public datatable
  When  I go to the the datatable page
  Then  I should see "download"
    And I should not see "sign up"
    And I should not see "sign in"
  When  I press "download"
  Then  I should download a file
    And the file should contain the data
    