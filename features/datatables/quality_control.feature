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
      And I go to the quality control page for "QC Me"
     Then I should be on the quality control page for "QC Me"
      And I should see "Time Series Graphs"
