Feature: Citation viewing and downloading
  In order to learn about research conducted at the sites
  As a User
  I want to download research papers produced at the site

  Scenario: An anonymous user visits the citations page
    When I go to the citations page
    Then I should see "Publications"

  Scenario: An anonymous user visits a citation page
    Given a citation exists with a title of "Earthworms"
     When I go to the citation page
     Then I should see "Earthworms"

  Scenario: A signed in user visits a citation page
    Given a citation exists with a title of "Corn weevil"
      And I have signed in with "bob@person.com/password"
     When I go to the citation page
     Then I should see "Corn weevil"

  Scenario: A signed in user visits the citation page
    Given I have signed in with "bob@person.com/password"
     When I go to the citations page
     Then I should see "Publications"

  Scenario: An anonymous user tries to add a citation and gets an error

  Scenario: An admin user adds a citation
    Given an admin user exists with an email of "admin@person.com"
    When I sign in as "admin@person.com/password"
      And I go to the new citation page
      And I fill in "Title" with "Corn weevil"
      And I attach the file "test/data/citation.pdf" to "Pdf"
    When I press "Create"
    Then I should see "Citation was successfully created."
      And I should see "Corn weevil"

  Scenario: An admin updates a citation
    Given I am signed in as an administrator
      And a citation exists with a title of "Old Title"
    When I go to the citation page
    Then I should see "Old Title"

    When I follow "Edit"
      And I fill in "Title" with "New Title"
      And I fill in "Doi" with "123"
      And I press "Update"
      And I go to the citation page
    Then I should see "New Title"
    And I should see "123"
