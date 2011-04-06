Feature: Quality Control
  In order to make sure that the data is accurate
  As a creator of the data
  I want to see the data displayed in graphs

  Background:
    Given the cache is clear
      And I am on the datatables page
      And a user exists and is confirmed with an email of "bob@person.com"

  Scenario: The admin user checks quality of a protected datatable
    Given a protected datatable exists with a name of "QC Me"
      And "bob@person.com" is an administrator
     When I sign in as "bob@person.com/password"
      And I go to the datatable show page for "QC Me"
      And I follow "Quality Control"
     Then I should be on the datatable quality control page for "QC Me"
      And I should see "Time Series Graphs"

  Scenario: The data owner checks quality of a datatable
    Given a protected datatable exists
      And "bob@person.com" owns the datatable
      And "bob@person.com" is not an administrator
     When I sign in as "bob@person.com/password"
     When I go to the datatable page
      And I follow "Quality Control"
     Then I should be on the datatable quality control page
      And I should see "Time Series Graphs"

  Scenario: Some other user tries to check quality of a datatable
    Given a protected datatable exists
      And "bob@person.com" does not own the datatable
      And "bob@person.com" is not an administrator
     When I sign in as "bob@person.com/password"
     When I go to the datatable page
      Then I should not see "Quality Control"