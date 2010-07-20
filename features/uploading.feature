Feature: Upload new studies.
  In order to share data
  A user wants to be able to upload a study.
  
Scenario: Upload an LTER file.
  Given I am in the LTER subdomain
  When I go to the new upload page
    And I fill in "Title" with "Does Singing to the Soil Cause Erosion?"
    And I fill in "Abstract" with "In this study, we show that singing can cause erosion, but only in large amounts. For example, a burst of song at 4.8 * 10^8 decibels would cause substantial amounts of erosion."
    And I fill in "List of Owners" with "David Berkowitz, Freddy Kruger, and Jason."
    And I attach the SingingSoil test file
    And I press "Submit Study"
    And I follow the redirect
  Then I should see "Study was uploaded!"
