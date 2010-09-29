Feature: Browsing Publications
  In order to see what publications are available
  As a normal user
  I want to see all of the publications

  Scenario: Going to the publication index to see publications
    Given a publication type exists with an id of "1"
      And a publication exists with a year of "1984"
      And I am signed in as a normal user
    When I go to the publications page
    Then I should see "1984"

#    When I follow "Show" within "tr#affiliation_1337"
#    Then I should see "Tech Guy"
#      And I should not see "Edit"
#      And I should see "Back"