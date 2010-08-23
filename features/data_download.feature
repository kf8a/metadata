
Feature: Download data
  In order to get data to analyze
  As a user
  I want to download datatables
  
  Background:
    Given I am on the datatables page
      And all caches are cleared

  Scenario: The admin user downloads a protected datatable
    Given a protected datatable exists
      And A user exists and is confirmed with an email of "bob@person.com"
      And "bob@person.com" is an administrator
     When I sign in as "bob@person.com"/"password"
      And I go to the datatable page
      And I follow "Download complete data table"
     Then I should be on the datatable download page
      And I should see "now"

  Scenario: The data owner downloads a datatable
    Given a protected datatable exists
      And "bob@person.com"/"password" owns the datatable
      And "bob@person.com" is not an administrator
     When I sign in as "bob@person.com"/"password"
     Then I should not have the "admin" role
      And I should be signed in
     When I go to the datatable page
      And I follow "Download complete data table"
     Then I should be on the datatable download page
      And I should see "now"

  Scenario: An authorized user downloads a datatable
    Given a protected datatable exists
      And "bob@person.com" has permission to download the datatable
      And "bob@person.com" is not an administrator
     When I sign in as "bob@person.com"/"password"
     Then I should not have the "admin" role
      And I should be signed in
     When I go to the datatable page
      And I follow "Download complete data table"
     Then I should be on the datatable download page
      And I should see "now"

  Scenario: A user requests access to a datatable
    Given a protected datatable exists
      And "bob@person.com" does not have permission to download the datatable
      And "bob@person.com" is not an administrator
     When I sign in as "bob@person.com"/"password"
     Then I should not have the "admin" role
      And I should be signed in
     When I go to the datatable page
     Then I should see "Request data"
      And I should not see "Download complete data table"
  
  Scenario: A user has received permission to download data from all data owners
    Given a protected datatable exists
      And "alice@person.com"/"password" owns the datatable
      And "bill@person.com"/"password" owns the datatable
      And "alice@person.com" has given "bob@person.com" permission
      And "bill@person.com" has given "bob@person.com" permission
     When I sign in as "bob@person.com"/"password"
      And I go to the datatable page
      And I follow "Download complete data table"
     Then I should be on the datatable download page
      And I should see "now"  

  Scenario: A user has received partial permission to download data
    Given I have signed in with "bob@person.com"/"password"
      And a protected datatable exists
      And "alice@person.com"/"password" owns the datatable
      And "bill@person.com"/"password" owns the datatable
      And "alice@person.com" has given "bob@person.com" permission
      And "bill@person.com" has not given "bob@person.com" permission
     When I sign in as "bob@person.com"/"password"
      And I go to the datatable page
     Then I should see "Request data"
      And I should not see "Download complete data table"
      And I should see "bill@person.com needs to give you permission"
      And I should see "alice@person.com has given you permission"

  
  Scenario: An anonymous user looks at a protected datatable 
    Given a protected datatable exists
     When I go to the datatable page
     Then I should not see "Download"
      And I should not see "Request data"
      And I should see "Sign in"
      And I should see "Sign up"
    
  Scenario: An anonymous user looks at a public datatable
    Given a public datatable exists
     When I go to the the datatable page
     Then I should see "Download"
      And I should not see "Sign up"
      And I should not see "Sign in"
     When I follow "Download"
     Then I should be on the datatable download page
      And I should see "now"
    
  Scenario: An anonymous users types in the url for a protected datatable html view
    Given a protected datatable exists
     When I go to the datatable download page
     Then I should see "Sign in"
      And I should see "Sign up"
      