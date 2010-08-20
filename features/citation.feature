Feature: Citation viewing and downloading
  In order to learn about research conducted at the sites
  As a User 
  I want to download research papers produced at the site
    
  Scenario: An anonymous user visits the citation page
    When I go to the citations page
    Then I should see "Citations"
     And I should not see "PDF"
    
  Scenario: A signed in user visits the citation page
    Given I have signed in with "bob@person.com"/"password"
      And citations exist
     When I go to the citations page
     Then I should see "Citations"
      And I should see "PDF"
      
  Scenario: An anonymous user tries to add a citation
    When I post to citations 
    Then I should get an error
    
  Scenario: A signed in user tries to add a citation
    When I post to citations
    Then I should be successful