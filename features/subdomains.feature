Feature: Use subdomains to divide up the site.
  In order to access areas with different permissions and standards
  A user wants to be able to go to different subdomains.
  
Scenario: Datatables index works on lter subdomain.
  Given I am in the LTER subdomain
  When I go to the datatables page
  Then I should see "The KBS LTER Data Catalog is a collection of publicly available datatables associated with the site."
  
Scenario: Datatables index works on GLBRC subdomain
  Given I am in the GLBRC subdomain
  When I go to the datatables page
  Then I should see "The Thrust 4 Data Catalog is a collection of GLBRC data related to sustainability research at different T4 research sites in Michigan and Wisconsin."
