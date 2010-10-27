Feature: Download data that was uploaded with upload feature.
   In order to prepare user uploaded files for inclusion in the database
      As an administrator
     I want to be able to download the files that users have uploaded
  
  Scenario: An admin downloads a GLBRC file
    Given I am signed in as an administrator
      And a file "test.dat" has been uploaded
    When I go to the uploads page
      And I follow "test.dat"
 #    Then I can download the file from the database
	
