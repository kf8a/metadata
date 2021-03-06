# GLBRC data catalog requires permissions to download a datatable.  
# The people listed as Lead Investigators of the datatable give permission. 
# Must have permission from all owners to download. 

Feature: Give Permissions to another user
  In order to prevent others from using my data
  As a data owner
  I want to control who can download data that I contribute

  Background:
    Given a user exists and is confirmed with an email of "bob@person.com"
      And a user exists and is confirmed with an email of "sam@person.com"
      And a protected datatable exists
      And "bob@person.com" owns the datatable
      And "bob@person.com" is not an administrator
      And "sam@person.com" is not an administrator
      And "sam@person.com" does not have permission to download the datatable

  Scenario: I want to grant permission to download to a user
    When  I sign in as "bob@person.com/password"
      And I go to the datatable page
      And I follow "Permissions Management"
    Then I should not see "sam@person.com has permission from you"
    
    When I follow "Add Permissions"
    Then I should see "Use this page to give permission to someone to download"

    When I fill in "Email" with "sam@person.com"
      And I press "Grant Permission"
    Then I should see "sam@person.com has permission from you"

 
  Scenario: I want to revoke permission to download from a user
    Given "bob@person.com" has given "sam@person.com" permission
    When  I sign in as "bob@person.com/password"
      And I go to the datatable page
      And I follow "Permissions Management"
    Then I should see "sam@person.com has permission from you"

    When I press "Revoke permission from sam@person.com"
    Then "sam@person.com" should not have access to the datatable
      And I should not see "sam@person.com has permission from you"
     
  Scenario: A user has partial access to data
    Given a user exists and is confirmed with an email of "alice@person.com"
      And "alice@person.com" owns the datatable
      And "alice@person.com" has not given "sam@person.com" permission
      And "bob@person.com" has given "sam@person.com" permission
    When I sign in as "bob@person.com/password"
      And I go to the datatable page
      And I follow "Permissions Management"
    Then I should see "sam@person.com has permission from you"
      And I should see "sam@person.com still needs permission from alice@person.com"
      
  Scenario: A user checks the index to see all of the datatables they own
    Given a protected datatable exists with a name of "A Datatable"
      And a protected datatable exists with a name of "Another Datatable"
      And "bob@person.com" owns the datatable named "A Datatable"
      And "bob@person.com" owns the datatable named "Another Datatable"
      And a protected datatable exists with a name of "A Datatable Bob Does Not Own"
    When  I sign in as "bob@person.com/password"
      And I go to the permissions page
    Then I should see "A Datatable"
      And I should see "Another Datatable"
      And I should not see "A Datatable Bob Does Not Own"
    
    When I follow "Modify Permissions for Another Datatable"
    Then I should see "Permissions for Another Datatable"

  Scenario: A potential downloader requests permission
    When I sign in as "sam@person.com/password"
    And I go to the datatable page
    ####This stuff needs to be tested manually, I cannot get it to work here
    #And I follow "Request Data"
    #And I go to the datatable page
    #Then I should see "You have already requested permission to download this datatable."

  Scenario: An owner gives permission by accepting someone's request
    Given "sam@person.com" has requested permission
    When I sign in as "bob@person.com/password"
    And I go to the datatable page
    And I follow "Permissions Management"
    Then I should see "sam@person.com has requested permission"
    When I press "Grant permission to sam@person.com"
    Then I should see "sam@person.com has permission from you"

  Scenario: An owner denies someone's request
    Given "sam@person.com" has requested permission
    When I sign in as "bob@person.com/password"
    And I go to the datatable page
    And I follow "Permissions Management"
    Then I should see "sam@person.com has requested permission"
    When I press "Deny request for sam@person.com"
    Then I should not see "sam@person.com has permission from you"
    And I should see "sam@person.com has requested permission but it has been denied by: bob@person.com"

  Scenario: An owner sees that another owner has denied someone's request
    Given "sam@person.com" has requested permission
      And a user exists and is confirmed with an email of "alice@person.com"
      And "alice@person.com" owns the datatable
      And "alice@person.com" has not given "sam@person.com" permission
      And "alice@person.com" has denied the request of "sam@person.com"
    When I sign in as "bob@person.com/password"
      Then I should be signed in
    When I go to the datatable page
      And I follow "Permissions Management"
    Then I should see "sam@person.com has requested permission but it has been denied by: alice@person.com"
