# GLBRC data catalog requires permissions to download a datatable.  
# The people listed as Lead Investigators of the datatable give permission. 
# Must have permission from all owners to download. 

Feature: Give Permissions to another user
  In order to prevent others from using my data
  As a data owner
  I want to control who can download data that I contribute

  Scenario: I want to grant permission to download to a user
    Given a protected datatable exists
      And "bob@person.com"/"password" owns the datatable
      And "bob@person.com" is not an administrator
      And "sam@person.com" does not have permission to download the datatable
      And "sam@person.com" is not an administrator
    When  I sign in as "bob@person.com"/"password"
      And I go to the datatable page
      And I follow "Permissions Management"
    Then I should not see "sam@person.com has permission from you"
    
    When I follow "Add Permissions"
    Then I should see "Use this page to give permission to someone to download"

    When I fill in "Email" with "sam@person.com"
      And I press "Grant Permission"
    Then I should see "sam@person.com has permission from you"

 
  Scenario: I want to revoke permission to download from a user
    Given a protected datatable exists
      And "bob@person.com"/"password" owns the datatable
      And "bob@person.com" has given "sam@person.com" permission
    When  I sign in as "bob@person.com"/"password"
      And I go to the datatable page
      And I follow "Permissions Management"
    Then I should see "sam@person.com has permission from you"

    When I press "Revoke permission from sam@person.com"
    Then "sam@person.com" should not have access to the datatable
      And I should not see "sam@person.com has permission from you"
     
  Scenario: A user has partial access to data
    Given a protected datatable exists
      And "alice@person.com"/"password" owns the datatable
      And "bob@person.com"/"password" owns the datatable
      And "alice@person.com" has not given "sam@person.com" permission
      And "bob@person.com" has given "sam@person.com" permission
    When I sign in as "bob@person.com"/"password"
      And I go to the datatable page
      And I follow "Permissions Management"
    Then I should see "sam@person.com has permission from you"
      And I should see "sam@person.com still needs permission from alice@person.com"
      
  Scenario: A user checks the index to see all of the datatables they own
    Given "bob@person.com"/"password" owns a datatable named "A Datatable"
      And "bob@person.com"/"password" owns a datatable named "Another Datatable"
      And a protected datatable exists named "A Datatable Bob Does Not Own"
    When  I sign in as "bob@person.com"/"password"
      And I go to the permissions page
    Then I should see "A Datatable"
      And I should see "Another Datatable"
      And I should not see "A Datatable Bob Does Not Own"
    
    When I follow "Modify Permissions for Another Datatable"
    Then I should see "Permissions for Another Datatable" 
