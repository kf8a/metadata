require File.expand_path('../test_helper',__dir__)

class UsersControllerTest < ActionController::TestCase
  context 'sign_up with invite' do
    setup do
      FactoryBot.create :sponsor, name: 'glbrc'
      @email = FactoryBot.generate(:email)
      @invite = FactoryBot.create :invite, email: 'bob@nospam.com', glbrc_member: true
      @invite.invite!

      get :create, params: { user: { email: @email,
                                     password: 'password', password_confirmation:  'password' },
                             invite_code: @invite.invite_code }
    end

    should 'result in a new user who is a member of the glbrc sponsor' do
      assert user = User.find_by(email: @email)

      assert user.sponsors.include?(Sponsor.find_by(name: 'glbrc'))
    end
  end

  context 'try to set the role yourself' do
    setup do
      get :create, params: { user: { email: FactoryBot.generate(:email), password: 'password',
                                     password_confirmation: 'password', role: 'admin' } }
    end

    should 'fail' do
      assert assigns(:user).role.nil?
    end
  end
end
