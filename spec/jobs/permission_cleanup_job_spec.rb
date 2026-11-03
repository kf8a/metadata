# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PermissionCleanupJob do
  let(:datatable) { FactoryBot.create(:datatable, is_restricted: true) }
  let(:admin) { FactoryBot.create(:admin_user) }

  def grant(expires_on)
    Permission.create!(datatable:, user: FactoryBot.create(:user), granted_by: admin, expires_on:)
  end

  it 'deletes permissions that expired more than 30 days ago and keeps the rest' do
    long_expired = grant(Date.current - 31)
    recently_expired = grant(Date.current - 5)
    active = grant(Date.current + 10)
    no_expiry = grant(nil)

    described_class.perform_now

    expect(Permission.all).to contain_exactly(recently_expired, active, no_expiry)
    expect(Permission.exists?(long_expired.id)).to be false
  end
end
