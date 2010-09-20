require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase
 
  context 'sign_up with invite' do
    setup do
      @invite = Factory.create :invite, :email => 'bob@nospam.com'
      @invite.invite!
      get :sign_up, :id => @invite.invite_code
    end
    
    should 'result in a new user with that email' do
      assert Users.find_by_email('bob@nospam.com')
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
