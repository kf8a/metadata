require File.expand_path('../../test_helper',__FILE__) 

class InviteTest < ActiveSupport::TestCase
  
  should validate_presence_of :email
  #should validate_uniqueness_of :email
  
  context 'inviting' do
    setup do
      @invite = Invite.create :email => Factory.next(:email)
    end
    
    should 'be invited' do
      assert @invite.invite!
      assert @invite.invited?
    end

  end
end
