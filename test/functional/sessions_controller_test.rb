require File.expand_path('../../test_helper',__FILE__) 

class SessionsControllerTest < ActionController::TestCase

  context 'shared public user' do
    context 'create' do
      setup do
       @user = FactoryGirl.create:user, :email => 'lter@lter.edu', :password => 'lter'
        post :create, :session => {:email => 'lter@lter.edu', :password => 'lter'}
      end
      should 'sign in the user' do
        assert_equal @user, @controller.current_user
      end
      # should respond_with :success
    end
  end

end
