Feature: depending on the first part of the host name it should show the appropriate template
  In order to conserve code
  As a developer 
  I want to reuse the same code to serve both websites
  
  Scenario: I go to the GLBRC datatable page
    When    I go to "GLBRC datatables"
    Then    I should see "GLBRC Datatable"
  
  Scenario: I go to the LTER datatable page
    When    I go to "LTER datatables"
    Then    I should see "Datatable"
      And   I should not see "GLBRC"