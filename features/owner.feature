Feature: Assign owners to datatables
  In order to manage who owns which table
  As an administrator
  I want to assign users as owners of datatables
  
  Scenario: An admin adds an owner to a datatable
    Given "admin@person.com" is an administrator
      And a protected datatable exists named "kbs001"
    When  I sign in as "admin@person.com"/"password"
      And I go to the datatable page
      And I follow "Owners Management"
    Then I should see "Owned by:"
      And I should not see "bill@person.com"
      And "bill@person.com" should not own the datatable "kbs001"
      
    When I follow "Add Owner"
    Then I should see "Use this page to add owners to kbs001"

    When I select "bill@person.com" from "user_1"
      And I press "Add Owners"
    Then I should see "bill@person.com"
      And  "bill@person.com" should own the datatable "kbs001"
  
  Scenario: An admin removes ownership from a user
    Given "admin@person.com" is an administrator
      And "bill@person.com"/"password" owns a datatable named "kbs001"
    When  I sign in as "admin@person.com"/"password"
      And I go to the datatable page
      And I follow "Owners Management"
    Then I should see "Owned by: bill@person.com"
      And I should see "bill@person.com"
      
    When I press "Revoke Ownership from bill@person.com"
    Then I should see "Ownership has been revoked from bill@person.com"
      And I should not see "Owned by: bill@person.com"
      And "bill@person.com" should not own the datatable "kbs001"
  
  Scenario: A signed in user tries to modify ownership
    Given "bob@person.com" is not an administrator
      And a protected datatable exists named "kbs001"
    When  I sign in as "bob@person.com"/"password"
      And I go to the ownerships page
    Then  I should be on the sign_in page
  
  Scenario: An anonymous user tries to modify ownership
    Given  "bob@person.com" is not an administrator
      And   a protected datatable exists named "kbs001"
    When  I go to the ownerships page
    Then  I should be on the sign_in page
