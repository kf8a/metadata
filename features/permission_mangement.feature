# GLBRC data catalog requires permissions to download a datatable.  
# The people listed as Lead Investigators of the datatable give permission. 
# Must have permission from all owners to download. 

Feature: Give Permissions to another user
  In order to prevent others from using my data
  As a data owner
  I want to control who can download data that I contribute

Scenario: I want to grant permission to download to a user
  Given I am signed in as "email@person.com"
    And I am the data owner
    And "bob@person.com" has requested access
  When I go to ....
  Then I should see ...

Scenario: I want to revoke permission to download from a user
  Given I am signed in as "email@person.com"
    And I am the data owner
    And "bob@person.com" has access to the datatable
  When I go to ....
  Then I should see "bob@person.com"
    And the "bob_permission" checkbox should be checked
  When I uncheck the checkbox
  Then "bob@person.com" does not have access to the datatable
    And the checkbox next to "bob@person.com" is unchecked
    
Scenario: A user has partial access to data
  Given I am signed in as "email@person.com"
    And I am the data owner
    And "bill" is the data owner
    And "bob@person.com" has been granted access by "me"
    And "bob@person.com" has not been granted access by "bill"
  When I go to ...
  Then I should see "bob@person"
    And the checkbox next to "bob@person.com" is checked
    And I see that "bill" has not granted access
  
    