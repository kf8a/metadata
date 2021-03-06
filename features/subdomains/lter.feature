Feature: Use subdomains to divide up the site.
  In order to access areas with different permissions and standards
  A user wants to be able to go to different subdomains.

Scenario: Datatables index works at LTER subdomain.
  Given I am in the LTER subdomain
  When I go to the datatables page
  Then I should see "Table of Contents"
  
Scenario: Sign in styles correctly in the LTER subdomain
  Given I am in the LTER subdomain
  When I go to the sign_in page
  Then I should see "The KBS LTER Site"
  When I go to the sign_up page
  Then I should see "The KBS LTER Site"
  # When I go to the password_reset page
  #  Then I should see "The KBS LTER site"
