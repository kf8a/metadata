require File.expand_path('../../test_helper',__FILE__)

class InviteTest < ActiveSupport::TestCase
  setup do
    FactoryGirl.create(:invite)
  end

  should validate_presence_of(:email).with_message("can't be blank")
  should validate_uniqueness_of(:email).with_message('is already registered')

  context 'inviting' do
    setup do
      @invite = FactoryGirl.create(:invite)
    end

    should 'be invited' do
      assert @invite.invite!
      assert @invite.invited?
    end
  end
end

# == Schema Information
#
# Table name: invites
#
#  id           :integer         not null, primary key
#  firstname    :string(255)
#  lastname     :string(255)
#  email        :string(255)
#  invite_code  :string(40)
#  invited_at   :datetime
#  redeemed_at  :datetime
#  glbrc_member :boolean
#
