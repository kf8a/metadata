Feature: Editing abstract
  In order to fix the abstract
  As an admin
  I want to edit an abstract

  Scenario: Admin edits an abstract
    Given the local venue type exists
      And an admin user exists with an email of "admin@person.com"
      And the following abstract exists:
      |title                |authors                        |abstract             |
      |"An Awesome Abstract"|"Abstract Guy and Abstract Gal"|"A testable abstract"|

    When I sign in as "admin@person.com"/"password"
      And I go to the abstracts page
      And I follow "An Awesome Abstract"
      And I follow "Edit"
    Then I should see "Editing Meeting Abstracts"

    When I fill in "Title" with "An Edited Abstract"
      And I press "Update"
    Then I should see "Meeting abstract was successfully updated."
      And I should not see "An Awesome Abstract"
      And I should see "An Edited Abstract"

    When I go to the abstracts page
    Then I should not see "An Awesome Abstract"
      And I should see "An Edited Abstract"

  Scenario: Admin fails to edit an abstract
    Given the local venue type exists
      And an admin user exists with an email of "admin@person.com"
      And the following abstract exists:
      |title                |authors                        |abstract             |
      |"An Awesome Abstract"|"Abstract Guy and Abstract Gal"|"A testable abstract"|

    When I sign in as "admin@person.com"/"password"
      And I go to the abstracts page
      And I follow "An Awesome Abstract"
      And I follow "Edit"
      And I fill in "Title" with "An Edited Abstract"
      And I fill in "Abstract" with ""
      And I press "Update"
    Then I should not see "Meeting abstract was successfully updated."
      And I should see "Editing Meeting Abstracts"

    When I go to the abstracts page
    Then I should see "An Awesome Abstract"
      And I should not see "An Edited Abstract"