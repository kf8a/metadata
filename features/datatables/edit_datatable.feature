
Feature: Download data
  In order to share my data with other
  As an administrator
  I want to create datatables

  Background:
    Given I am on the datatables page
      And I am signed in as an administrator

  @javascript
  Scenario: The user edits a datatable
    Given an old datatable exists with title: "Old Datatable"
    When I go to the datatable page
      And I follow "Edit"
      And I follow "Update Temporal Coverage"
      And I wait for 3 seconds
      And I press "Update"
    Then I should see the old date