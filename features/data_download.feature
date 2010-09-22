
Feature: Download data
  In order to get data to analyze
  As a user
  I want to download datatables
  
  Background:
    Given I am on the datatables page
      And a user exists and is confirmed with an email of "bob@person.com"

  Scenario: The admin user downloads a protected datatable
    Given a protected datatable exists
      And "bob@person.com" is an administrator
     When I sign in as "bob@person.com"/"password"
      And I go to the datatable page
      And I follow "Download complete data table"
     Then I should be on the datatable download page
      And I should see "1"

  Scenario: The data owner downloads a datatable
    Given a protected datatable exists
      And "bob@person.com" owns the datatable
      And "bob@person.com" is not an administrator
     When I sign in as "bob@person.com"/"password"
     When I go to the datatable page
      And I follow "Download complete data table"
     Then I should be on the datatable download page
      And I should see "1"
      
  Scenario: A sponsor member downloads a datatable
     Given a protected datatable exists
       And the datatable sponsored by "glbrc"
       And "bob@person.com" owns the datatable
       And "bob@person.com" is not an administrator
       And "bob@person.com" is a "glbrc" member
      When I sign in as "bob@person.com"/"password"
      When I go to the datatable page
       And I follow "Download complete data table"
      Then I should be on the datatable download page
       And I should see "1"

  Scenario: An authorized user downloads a datatable
    Given a protected datatable exists
      And "bob@person.com" has permission to download the datatable
      And "bob@person.com" is not an administrator
      And "bob@person.com" does not own the datatable
     When I sign in as "bob@person.com"/"password"
     When I go to the datatable page
      And I follow "Download complete data table"
     Then I should be on the datatable download page
      And I should see "1"

  Scenario: A user requests access to a datatable
    Given a protected datatable exists
      And "bob@person.com" does not have permission to download the datatable
      And "bob@person.com" is not an administrator
      And "bob@person.com" does not own the datatable
    When I sign in as "bob@person.com"/"password"
      And I go to the datatable page
    Then I should see "Request Data"
      And I should not see "Download complete data table"
  
  Scenario: A user has received permission to download data from all data owners
    Given a protected datatable exists with a name of "Double Trouble"
      And a user exists and is confirmed with an email of "alice@person.com"
      And a user exists and is confirmed with an email of "bill@person.com"
      And "alice@person.com" owns the datatable named "Double Trouble"
      And "bill@person.com" owns the datatable named "Double Trouble"
      And "alice@person.com" has given "bob@person.com" permission for "Double Trouble"
      And "bill@person.com" has given "bob@person.com" permission for "Double Trouble"
     When I sign in as "bob@person.com"/"password"
      And I go to the datatable show page for "Double Trouble"
      And I follow "Download complete data table"
     Then I should be on the datatable download page
      And I should see "1"  

  Scenario: A user has received partial permission to download data
    Given a user exists and is confirmed with an email of "alice@person.com"
      And a user exists and is confirmed with an email of "bill@person.com"
      And a protected datatable exists
      And "alice@person.com" owns the datatable
      And "bill@person.com" owns the datatable
      And "alice@person.com" has given "bob@person.com" permission
      And "bill@person.com" has not given "bob@person.com" permission
     When I sign in as "bob@person.com"/"password"
      And I go to the datatable page
     Then I should see "Request Data"
      And I should not see "Download complete data table"

  Scenario: An anonymous user looks at a protected datatable 
    Given a protected datatable exists
     When I go to the datatable page
     Then I should not see "Download"
      And I should not see "Request Data"
      And I should see "Sign in"
    
  Scenario: An anonymous user looks at a public datatable
    Given a public datatable exists
     When I go to the the datatable page
     Then I should see "Download"
      And I should not see "Sign in"
     When I follow "Download"
     Then I should be on the datatable download page
      And I should see "1"
    
  Scenario: An anonymous users types in the url for a protected datatable html view
    Given a protected datatable exists
     When I go to the datatable download page
     Then I should see "Sign in"
      
