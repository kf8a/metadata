
Feature: Download data
  In order to share my data with other
  As an administrator
  I want to create datatables

  Background:
    Given I am on the datatables page
      And I am signed in as an administrator

  @javascript
  Scenario: The user creates a datatable
    Given a dataset exists with a title of "Generic Dataset"
      And a person exists with a sur name of "Jones"
      And a role exists with a name of "Uploader"

     When I go to the new datatable page
      And I fill in "Title" with "Generic Datatable"
      And I select "Generic Dataset" from "Dataset"
      And I follow "Add Person"
      And I select "Jones" from "Person"
      And I select "Uploader" from "Role"
      And I follow "Add Variate"
      And I select "text" from "Data type"
      And I press "Create"
     Then I should see "Generic Datatable"
      And I should see "Generic Dataset"
      And I should see "Jones"
