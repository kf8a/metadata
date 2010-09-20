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
end
