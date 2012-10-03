require File.expand_path('../../test_helper',__FILE__) 

class SessionsControllerTest < ActionController::TestCase

  context 'shared public user' do
    context 'create' do
      setup do
        @user = Factory.create :user, :email => 'lter@kbs.edu', :password => 'lter'
        post :create, :session => {:email => 'lter', :password => 'lter', :openid_url => ''}
      end
      should respond_with :success
      should 'sign in the user' do
        assert_equal @user, @controller.current_user
      end
    end
  end

end
