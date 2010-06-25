Feature: permissions to download a GLBRC datatable
	GLBRC data catalog requires permissions to download a datatable.  
	The people listed as Lead Investigators of the datatable give permission. 
	Must have permission from all owners to download. 

Background:
  Given one owner with the role 'Lead Investigator'
  And a person that wants to download data named 'data requester'
  And a person that has been given permission named 'approved'
  And a person that has not been given permission named 'not approved'
  And datatables have one or many Lead Investigators
  And datatables also have none to many 'approved'

Scenario: Someone tries to download data
	Given they are not logged in
	Then they are asked to log in
	
Scenario: Lead Investigator wants to download datatable
	Given I am logged in as Lead Investigator
	When I try to download my datatable
	Then I am able to download my datatable
	
Scenario: "approved" wants to download a datatable
	Given I am logged in as "approved"
	When I try to download a datatable
	Then I am able to download the datatable	
	
Scenario: "not approved" wants to download datatable
	Given I am logged in as "not approved"	
	When I try to download a datatable
	Then email opens addressed to all 'Lead Investigators' and GLBRC Data Coordinator 
	And email subject "GLBRC data request"
	And email text "How do you plan to use the data?"
	
Scenario: Lead Investigator logs in
 	Given I am Lead Investigator on at least one datatable
	And I am logged in
	Then I can see a list of the datatables that I own
	And I see who the "data requesters" are for those datatables
	And if I have given given permission to the requesters to download the datatables 
	And who else has given permission for each of my datatables to be released 
	And who else needs to give permission for datatable to be released??
	Then I can give "data requesters" permission	

	
	
