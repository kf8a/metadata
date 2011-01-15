Feature: Creating abstract
  In order to provide a quick overview
  As an admin
  I want to create an abstract

  Scenario: Admin creates an abstract
    Given the local venue type exists
      And an admin user exists with an email of "admin@person.com"
      And a meeting exists with a title of "Long Meeting"
    When I sign in as "admin@person.com"/"password"
      And I go to the meetings page
      And I follow "Long Meeting"
      And I follow "Add abstract"
    Then I should see "New Meeting Abstract"

    When I fill in "Title" with "Short Abstract"
      And I fill in "Authors" with "Short Guy and Short Gal"
      And I fill in "Abstract" with "This was a super long meeting guys."
      And I press "Create"
    Then I should see "Meeting Abstract was successfully created."
      And I should see "Short Guy and Short Gal"
      And I should see "Short Abstract"
      And I should see "Edit"

  Scenario: Admin forgets to put in an abstract
    Given the local venue type exists
      And an admin user exists with an email of "admin@person.com"
      And a meeting exists with a title of "Long Meeting"
    When I sign in as "admin@person.com"/"password"
      And I go to the meetings page
      And I follow "Long Meeting"
      And I follow "Add abstract"
      And I fill in "Title" with "Short Abstract"
      And I fill in "Authors" with "Short Guy and Short Gal"
      And I fill in "Abstract" with ""
      And I press "Create"
    Then I should not see "Meeting Abstract was successfully created."

  Scenario: Admin deletes an abstract
    Given the local venue type exists
      And an admin user exists with an email of "admin@person.com"
      And the following abstract exists:
      |title                |authors                        |abstract             |
      |"An Awesome Abstract"|"Abstract Guy and Abstract Gal"|"A testable abstract"|

    When I sign in as "admin@person.com"/"password"
      And I go to the abstracts page
      And I follow "An Awesome Abstract"
      And I follow "Destroy"
    Then I should not see "An Awesome Abstract"

    When I go to the abstracts page
      Then I should not see "An Awesome Abstract"

@javascript
Scenario: Admin deletes an abstract from the meeting page
    #This is tested in meeting_abstracts.sel
    Given the local venue type exists
      And I am signed in as an administrator
      And the following abstract exists:
      |title                |authors                        |abstract             |
      |"An Awesome Abstract"|"Abstract Guy and Abstract Gal"|"A testable abstract"|

    When I go to the abstracts page
      And I follow "An Awesome Abstract"
      And I follow "Back to meeting"
      And I confirm a js popup on the next step
      And I follow "Trash"
      And I wait for 3 seconds
      Then I should not see hidden text "An Awesome Abstract"

    When I go to the abstracts page
    Then I should not see "An Awesome Abstract"