Feature: Use subdomains to divide up the site.
  In order to access areas with different permissions and standards
  A user wants to be able to go to different subdomains.

Scenario: Datatables index works at GLBRC subdomain.
  Given I am in the GLBRC subdomain
  When I go to the datatables page
  Then I should see "This catalog is a collection of the data from the GLBRC sustainability research sites in Michigan and Wisconsin"

Scenario: Sign in styles correctly in the GLBRC subdomain
  Given I am in the GLBRC subdomain
  When I go to the sign_in page
  Then I should see "GLBRC"
  # When I go to the sign_up page
  # Then I should see "GLBRC"
  # When I go to the password_reset page
  # Then I should see "GLBRC"

