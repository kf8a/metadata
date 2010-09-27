Feature: Browsing Abstract
  In order to see what abstracts are available
  As a normal user
  I want to see all of the abstracts

  Scenario: Going to the abstract index to see abstracts
    Given the following abstract exists:
      |title                |authors                        |abstract|
      |"An Awesome Abstract"|"Abstract Guy and Abstract Gal"|"A testable abstract"|

      And I am signed in as a normal user
    When I go to the abstracts page
    Then I should see "An Awesome Abstract"
      And I should see "Abstract Guy and Abstract Gal"

    When I follow "An Awesome Abstract"
    Then I should see "An Awesome Abstract"
      And I should see "Abstract Guy and Abstract Gal"
      And I should see "A testable abstract"
      And I should see "Index"
      And I should see "log out"
      And I should not see "Edit"
      And I should not see "Destroy"