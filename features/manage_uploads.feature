Feature: Manage uploads
  In order to add data into the metadata system
  the data generator
  wants to upload data files for processing by the information management staff
  
  Scenario: Register new upload
    Given I am on the new upload page
    And I am a logged_in
    When I fill in "Title" with "title 1"
    And I fill in "Description" with "description 1"
    And I fill in "Data" with "data 1"
    And I press "Create"
    Then I should see "title 1"
    And I should see "description 1"
    And I should see "data 1"

  Scenario: Delete upload
    Given the following uploads:
      |title|description|data|
      |title 1|description 1|data 1|
      |title 2|description 2|data 2|
      |title 3|description 3|data 3|
      |title 4|description 4|data 4|
    When I delete the 3rd upload
    Then I should see the following uploads:
      |Title|Description|Data|
      |title 1|description 1|data 1|
      |title 2|description 2|data 2|
      |title 4|description 4|data 4|
