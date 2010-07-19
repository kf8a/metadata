Given /^I am signed in as admin$/ do
  email = 'person@email.com'
  password = 'password'
  Factory :admin_user,
       :email                 =>  email,
       :password              => password,
       :password_confirmation => password
       
  And %{I sign in as "#{email}/#{password}"}
end
