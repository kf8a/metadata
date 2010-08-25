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
     
  Scenario: A signed in user visits a citation page
    Given a citation with the title "Corn weevil" 
      And I have signed in with "bob@person.com"/"password"
     When I go to the citation page
     Then I should see "Corn weevil"
    
  Scenario: A signed in user visits the citation page
    Given I have signed in with "bob@person.com"/"password"
     When I go to the citations page
     Then I should see "Publications"
      
  Scenario: An anonymous user tries to add a citation and gets an error
    
  Scenario: A signed in user tries to add a citation
    Given I have signed in with "admin@person.com"/"password"
#      And "admin@person.com" is an administrator
     When I go to the new citation page
      And I fill in "title" with "Corn weevil"
      And I attach the file "test/citation.pdf" to "pdf"
     When I press "Create"
     Then I should see "created successfully"
      And I should see "Corn weevil"
