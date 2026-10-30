# frozen_string_literal: true

require 'rails_helper'

describe Permission do
  include ActiveSupport::Testing::TimeHelpers

  let(:datatable) { FactoryBot.create(:datatable, is_restricted: true) }
  let(:admin) { FactoryBot.create(:admin_user) }
  let(:user) { FactoryBot.create(:user) }

  def grant(expires_on: nil, granted_by: admin, to: user)
    Permission.create(datatable:, user: to, granted_by:, expires_on:)
  end

  it 'can only be granted by an admin, even if the granter owns the datatable' do
    owner = FactoryBot.create(:user)
    Ownership.create!(user: owner, datatable:)

    expect(grant(granted_by: owner)).not_to be_persisted
    expect(grant(granted_by: admin)).to be_persisted
  end

  describe 'expiry' do
    it 'turns an expiry choice into a date, with 90 days by default' do
      travel_to Date.new(2026, 1, 1) do
        expect(Permission.expiry_for('30')).to eq Date.new(2026, 1, 31)
        expect(Permission.expiry_for(nil)).to eq Date.new(2026, 4, 1)
        expect(Permission.expiry_for('12345')).to eq Date.new(2026, 4, 1)
        expect(Permission.expiry_for('never')).to be_nil
      end
    end

    it 'counts a permission as active through its last day, and without an expiry' do
      travel_to Date.new(2026, 1, 10) do
        expect(grant(to: FactoryBot.create(:user), expires_on: Date.new(2026, 1, 10))).to be_active
        expect(grant(to: FactoryBot.create(:user), expires_on: nil)).to be_active
        expect(grant(to: FactoryBot.create(:user), expires_on: Date.new(2026, 1, 9))).not_to be_active
        expect(Permission.active.count).to eq 2
      end
    end
  end

  describe 'when someone is deleted' do
    it 'drops the permissions and requests of a deleted user' do
      grant
      PermissionRequest.create!(user:, datatable:)

      user.destroy

      expect(Permission.count).to eq 0
      expect(PermissionRequest.count).to eq 0
    end

    it 'drops the permissions and requests of a deleted datatable' do
      grant
      PermissionRequest.create!(user:, datatable:)

      datatable.destroy

      expect(Permission.count).to eq 0
      expect(PermissionRequest.count).to eq 0
    end

    it 'keeps a permission when the admin who granted it is deleted' do
      grant

      admin.destroy

      expect(datatable.permitted?(user)).to be true
    end
  end

  describe 'Datatable#permitted? and downloading' do
    it 'lets a user with an active permission download a restricted datatable' do
      grant(expires_on: Date.current + 1)

      expect(datatable.permitted?(user)).to be true
      expect(datatable.can_be_downloaded_by?(user)).to be true
    end

    it 'stops once the permission has expired' do
      grant(expires_on: Date.current - 1)

      expect(datatable.permitted?(user)).to be false
      expect(datatable.can_be_downloaded_by?(user)).to be false
    end

    it 'works for a datatable that has no owners' do
      expect(datatable.owners).to be_empty
      grant

      expect(datatable.can_be_downloaded_by?(user)).to be true
    end

    it 'opens a members-only datatable to someone who is not a member' do
      members_only = FactoryBot.create(:protected_datatable)
      expect(members_only.can_be_downloaded_by?(user)).to be false

      Permission.create!(datatable: members_only, user:, granted_by: admin)

      expect(members_only.can_be_downloaded_by?(user)).to be true
    end

    it 'does not carry over to another datatable' do
      grant

      expect(FactoryBot.create(:datatable, is_restricted: true).permitted?(user)).to be false
    end
  end
end
