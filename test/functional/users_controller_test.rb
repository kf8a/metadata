require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < ActionController::TestCase
 
  context 'sign_up with invite' do
    setup do
      Factory.create :sponsor, :name=>'glbrc'
      @email = Factory.next(:email)
      @invite = Factory.create :invite, :email => 'bob@nospam.com' , :glbrc_member  => true
      @invite.invite!

      get :create, :user => { :email => @email, 
                              :password => 'password', :password_confirmation => 'password'},
                              :invite_code => @invite.invite_code
    end
    
    should 'result in a new user who is a member of the glbrc sponsor' do
      assert user = User.find_by_email(@email)

      assert user.sponsors.include?(Sponsor.find_by_name('glbrc'))
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
