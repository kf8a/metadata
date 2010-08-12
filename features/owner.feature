Feature: Assign owners to datatables
  In order to manage who owns which table
  As an administrator
  I want to assign users as owners of datatables
  
  Scenario: An admin adds an owner to a datatable
    Given "admin@person.com" is an administrator
     And  a protected datatable "kbs001" exists
    When  I sign in as "admin@person.com"/"password"
    And   I go to the ownership page
    And   I select "bill@person.com"
    And   I select datatable "kbs001"
    And   I press "Set Owner"
    Then  "bill@person.com" owns the datatable "kbs001"
    
  Scenario: A signed in user tries to modify ownership
    Given "bob@person.com" is not a administrator
    And   a protected datatable "kbs001" exists
    When  I sign in as "bob@person.com"/"password"
    And   I go to the ownership page
    Then  I should be on the sign_in page
  
  Scenario: An anonymous user tries to modify ownership
  Given  "bob@person.com" is not a administrator
   And   a protected datatable "kbs001" exists
   When  I go to the ownership page
   Then  I should be on the sign_in page
  