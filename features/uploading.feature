Feature: Upload new studies.
  In order to share data
  A user wants to be able to upload a study.
  
Scenario: An admin uploads an LTER file.
  Given I am in the LTER subdomain
    And I am signed in as an administrator
  When I go to the new upload page
    And I fill in "Data Table Title" with "Does Singing Cause Erosion?"
    And I fill in "Abstract" with "In this study, we show that singing can cause erosion, but only in large amounts. For example, a burst of song at 4.8 * 10^8 decibels would cause substantial amounts of erosion."
    And I fill in "Responsible PI's" with "N. Owner and others"
    And I attach the SingingSoil test file
    And I press "Submit"
    And I follow the redirect
   Then I should see "Study was uploaded!"

Scenario: An uploader uploads a file in the GLBRC domain
  Given I am in the GLBRC subdomain
    And I am signed in as an uploader
  When I go to the new upload page
    And I fill in "Data Table Title" with "Does Singing Cause Erosion?"
    And I fill in "Abstract" with "In this study, we show that singing can cause erosion, but only in large amounts. For example, a burst of song at 4.8 * 10^8 decibels would cause substantial amounts of erosion."
    And I fill in "Responsible PI's" with "N. Owner and others"
    And I attach the SingingSoil test file
    And I press "Submit"
    And I follow the redirect
   Then I should see "Study was uploaded!"
