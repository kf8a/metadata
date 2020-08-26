# frozen_string_literal: true

require File.expand_path('../test_helper', __dir__)

class SessionsControllerTest < ActionController::TestCase
  context 'shared public user' do
    context 'create' do
      setup do
        @user = FactoryBot.create :user, email: 'lter@lter.edu', password: 'lter'
        post :create, params: { session: { email: 'lter@lter.edu', password: 'lter' } }
      end
      should 'sign in the user' do
        assert_equal @user, @controller.current_user
      end
      # should respond_with :success
    end
  end
end
