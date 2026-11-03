# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UnusedInvitationCleanupJob do
  include ActiveSupport::Testing::TimeHelpers

  let(:datatable) { FactoryBot.create(:datatable, is_restricted: true) }
  let(:admin) { FactoryBot.create(:admin_user) }

  # As PermissionsController does: a placeholder account, its permission, and a sent link
  def invite(email)
    reader = User.new(email:, first_name: 'Ada', last_name: 'Reader', institution: 'MSU')
    reader.invite!(admin) { |user| user.skip_invitation = true }
    reader.current_invitation.update!(invitation_sent_at: Time.current)
    Permission.create!(datatable:, user: reader, granted_by: admin, expires_on: Date.current + 90)
    reader
  end

  it 'deletes accounts whose newest link expired more than 30 days ago, with their permissions' do
    unused = travel_to(45.days.ago) { invite('unused@example.org') }
    reinvited = travel_to(45.days.ago) { invite('reinvited@example.org') }
    travel_to(5.days.ago) { reinvited.invite!(admin) { |user| user.skip_invitation = true } }
    waiting = travel_to(20.days.ago) { invite('waiting@example.org') }
    accepted = travel_to(45.days.ago) { invite('accepted@example.org') }
    travel_to(40.days.ago) do
      User.accept_invitation!(invitation_token: accepted.raw_invitation_token, password: 'a-long-password')
    end
    member = FactoryBot.create(:user)

    described_class.perform_now

    expect(User.all).to contain_exactly(admin, reinvited, waiting, accepted, member)
    expect(Permission.where(user_id: unused.id)).to be_empty
    expect(DeviseInvitable::Invitation.where(invitable_id: unused.id)).to be_empty
  end
end
