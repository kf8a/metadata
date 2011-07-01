
Feature: Download data
  In order to share my data with other
  As an administrator
  I want to create datatables

  Background:
    Given I am on the datatables page
      And I am signed in as an administrator

  Scenario: The user edits a datatable
    Given an old datatable exists with title: "Old Datatable", number_of_released_records: 0
    When I go to the datatable page
      And I follow "Edit"
    Then I should see "Currently, 0 are approved out of 1"

    When I press "Approve all current records"
    Then I should see "Currently, 1 are approved out of 1"
