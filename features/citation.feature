Feature: Citation viewing and downloading
  In order to learn about research conducted at the sites
  As a User 
  I want to download research papers produced at the site
    
  Scenario: An anonymous user visits the citations page
    When I go to the citations page
    Then I should see "Publications"
    
  Scenario: An anonymous user visits a citation page
    Given a citation with the title "Earthworms"
     When I go to the citation page
     Then I should see "Earthworms"
      And I should not see "PDF"
     
  Scenario: A signed in user visits a citation page
    Given a citation with the title "Corn weevil" 
      And I have signed in with "bob@person.com"/"password"
     When I go to the citation page
     Then I should see "Corn weevil"
      And I should see "PDF"
    
  Scenario: A signed in user visits the citation page
    Given I have signed in with "bob@person.com"/"password"
     When I go to the citations page
     Then I should see "Publications"
      
  Scenario: An anonymous user tries to add a citation
    When I post to citations 
    Then I should get an error
    
  Scenario: A signed in user tries to add a citation
    When I post to citations
    Then I should be successful