require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase
 
  context 'sign_up with invite' do
    setup do
      @invite = Factory.create :invite, :email => 'bob@nospam.com'
      @invite.invite!
      @email = Factory.next(:email)
      get :create, :invite => @invite.invite_code, :email => @email, 
        :password => 'password', :password_confirmation => 'password'
    end
    
    should 'result in a new user with that email' do
      assert User.find_by_email(@email)
    end
    
  end
  
  context 'try to set the role yourself' do
    setup do
      get :create, :email => Factory.next(:email), :password => 'password', 
          :password_confirmation => 'password', :role => 'admin'
    end
    
    should 'fail' do 
      assert assigns(:user).role.nil?
    end
  end
end
