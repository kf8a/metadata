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

  describe 'granting' do
    it 'is valid when an admin grants it' do
      expect(grant).to be_persisted
    end

    it 'is refused when someone who is not an admin grants it, even an owner' do
      owner = FactoryBot.create(:user)
      Ownership.create!(user: owner, datatable:)

      permission = grant(granted_by: owner)

      expect(permission).not_to be_persisted
      expect(permission.errors[:granted_by]).to include('must be an admin')
    end

    it 'allows one permission per user and datatable' do
      grant

      expect(grant(granted_by: FactoryBot.create(:admin_user))).not_to be_persisted
    end

    it 'keeps a permission carried over from an owner approval valid when it is changed later' do
      owner = FactoryBot.create(:user)
      carried_over = grant
      carried_over.update_column(:owner_id, owner.id) # rubocop:disable Rails/SkipsModelValidations -- as the migration leaves it

      expect(carried_over.reload.update(expires_on: Date.current + 30)).to be true
    end
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

  describe 'when users or datatables are deleted' do
    # delete skips Rails callbacks, so these show the database's foreign keys at work
    it 'drops the permissions and requests of a deleted user' do
      grant
      PermissionRequest.create!(user:, datatable:)

      user.delete

      expect(Permission.count).to eq 0
      expect(PermissionRequest.count).to eq 0
    end

    it 'keeps a permission when the admin who granted it is deleted' do
      permission = grant

      admin.delete

      expect(permission.reload.granted_by).to be_nil
      expect(datatable.permitted?(user)).to be true
    end

    it 'drops the permissions and requests of a deleted datatable' do
      grant
      PermissionRequest.create!(user:, datatable:)

      datatable.delete

      expect(Permission.count).to eq 0
      expect(PermissionRequest.count).to eq 0
    end

    it 'does the same when a user is destroyed through Rails' do
      grant

      user.destroy

      expect(Permission.count).to eq 0
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
