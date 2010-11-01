require File.expand_path('../../test_helper',__FILE__) 

class InviteTest < ActiveSupport::TestCase

  setup do
    Factory.create(:invite)
  end

  should validate_presence_of :email
  should validate_uniqueness_of(:email).with_message("is already registered")
  
  context 'inviting' do
    setup do
      @invite = Factory.create(:invite)
    end
    
    should 'be invited' do
      assert @invite.invite!
      assert @invite.invited?
    end

  end
end
