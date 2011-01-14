Feature: All the javascripts should work properly
  In order to use the website more dynamically
  As a user
  I want to be able to use javascript

  @watir
  Scenario: An admin creates and then deletes an abstract
    Given JS I am signed in as an administrator
      And JS a venue type exists
    When JS I go to the new meeting page
      And JS I fill in "meeting_title" with "Long Meeting"
      And JS I press "Create"
      And JS I follow "Long Meeting"
      And JS I follow "Add abstract"
      And JS I fill in "abstract_title" with "An Awesome Abstract"
      And JS I fill in "abstract_authors" with "Awesome Guy and Awesome Gal"
      And JS I fill in "abstract_abstract" with "A testable abstract"
      And JS I press "Create"
    Then JS I should see "Awesome Guy and Awesome Gal An Awesome Abstract Edit"
    When JS I go to the meetings page
      And JS I follow "Long Meeting"
    Then JS I should see "Awesome Guy and Awesome Gal"
    
    When JS I follow "Trash"
    Then JS I should not see "Awesome Guy and Awesome Gal"
    When JS I go to the meetings page
      And JS I follow "Long Meeting"
    Then JS I should not see "Awesome Guy and Awesome Gal"
