require 'test_helper'

class InviteTest < ActiveSupport::TestCase
  
  should validate_presence_of :email
  should validate_uniqueness_of :email
 
  context 'inviting' do
    setup do
      @invite = Invite.new
      @invite.invite!
    end
    
    should 'generate an invite code' do
      assert @invite.code.length > 0
    end

  end
end
