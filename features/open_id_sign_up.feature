Feature: Sign up with openid
  In order to get access to protected sections of the site
  A user
  Should be able to sign up using their openid provider
  
Scenario: User signs up with openid
  Given I have an openid provider
  When I go to the sign up page
  And I fill in "Email" with "email@person.com"
  When I press "Sign up"
  Then I will be redirected to the the openid provider
  When I return 
  Then I will be logged on
  And my email address will be stored
