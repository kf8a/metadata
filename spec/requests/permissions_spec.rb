# frozen_string_literal: true

require 'rails_helper'

# Admins grant, extend and revoke permission to download restricted and members-only datatables.
RSpec.describe 'Managing download permissions', type: :request do
  include Devise::Test::IntegrationHelpers
  include ActiveSupport::Testing::TimeHelpers

  let(:website) { Website.find_by(name: 'lter') || Website.create!(name: 'lter', url: 'lter.kbs.msu.edu') }
  let(:datatable) do
    FactoryBot.create(:datatable, is_restricted: true, dataset: FactoryBot.create(:dataset, website:),
                                  object: "select '2020-01-01'::date as sample_date")
  end
  let(:admin) { FactoryBot.create(:admin_user) }
  let(:reader) { FactoryBot.create(:user, email: 'reader@example.org') }

  def grant(email, expires_in: nil)
    post permissions_path, params: { datatable: datatable.id, email:, expires_in: }.compact
  end

  describe 'who can manage permissions' do
    it 'sends a visitor to sign in' do
      get permission_path(datatable)

      expect(response).to redirect_to(new_user_session_path)
    end

    it 'turns away an owner who is not an admin' do
      owner = FactoryBot.create(:user)
      Ownership.create!(user: owner, datatable:)
      sign_in owner

      get permission_path(datatable)
      expect(response).to redirect_to(new_user_session_url)

      post permissions_path, params: { datatable: datatable.id, email: reader.email }
      expect(Permission.count).to eq 0
    end

    it 'lists restricted and members-only datatables for an admin, but not open ones' do
      members_only = FactoryBot.create(:protected_datatable, name: 'MEMBERS-1')
      open_table = FactoryBot.create(:datatable, name: 'OPEN-1')
      datatable.update!(name: 'RESTRICTED-1')
      sign_in admin

      get permissions_path

      expect(response.body).to include('RESTRICTED-1', members_only.name)
      expect(response.body).not_to include(open_table.name)
    end
  end

  describe 'granting' do
    before { sign_in admin }

    it 'grants for 90 days by default and clears the request' do
      PermissionRequest.create!(user: reader, datatable:)

      travel_to Date.new(2026, 3, 1) do
        grant('Reader@Example.org ')

        expect(response).to redirect_to(permission_path(datatable))
        expect(flash[:notice]).to eq "reader@example.org may download #{datatable.name} until May 30, 2026."
      end
      permission = datatable.permissions.find_by!(user: reader)
      expect(permission.expires_on).to eq Date.new(2026, 5, 30)
      expect(permission.granted_by).to eq admin
      expect(PermissionRequest.where(user: reader, datatable:)).to be_empty
    end

    it 'grants with another lifetime, or with no expiry' do
      grant(reader.email, expires_in: 'never')

      expect(datatable.permissions.find_by!(user: reader).expires_on).to be_nil
    end

    it 'extends an existing permission from today instead of adding a second one' do
      Permission.create!(datatable:, user: reader, granted_by: FactoryBot.create(:admin_user),
                         expires_on: Date.current - 5)

      grant(reader.email, expires_in: '30')

      expect(datatable.permissions.where(user: reader).count).to eq 1
      expect(datatable.permissions.find_by!(user: reader)).to have_attributes(expires_on: Date.current + 30,
                                                                              granted_by: admin)
    end

    it 'extends a permission whose granting admin has since been deleted' do
      Permission.create!(datatable:, user: reader, granted_by: FactoryBot.create(:admin_user)).granted_by.delete

      grant(reader.email)

      expect(datatable.permissions.find_by!(user: reader).granted_by).to eq admin
    end

    it 'explains when no account has that email' do
      grant('nobody@example.org')

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('No account has the email nobody@example.org')
      expect(Permission.count).to eq 0
    end

    it 'shows requests and grants on the datatable page' do
      PermissionRequest.create!(user: FactoryBot.create(:user, email: 'asker@example.org'), datatable:)
      Permission.create!(datatable:, user: reader, granted_by: admin, expires_on: Date.new(2030, 5, 1))

      get permission_path(datatable)

      expect(response.body).to include('asker@example.org has asked', 'reader@example.org', 'May 01, 2030')
    end
  end

  describe 'revoking and dismissing' do
    before { sign_in admin }

    it 'revokes a permission' do
      Permission.create!(datatable:, user: reader, granted_by: admin)

      delete permission_path(datatable), params: { user: reader.id }

      expect(response).to redirect_to(permission_path(datatable))
      expect(datatable.permitted?(reader)).to be false
    end

    it 'dismisses a request without granting it' do
      PermissionRequest.create!(user: reader, datatable:)

      delete dismiss_permission_path(datatable), params: { user: reader.id }

      expect(PermissionRequest.where(user: reader)).to be_empty
      expect(datatable.permitted?(reader)).to be false
    end
  end

  describe 'what the reader can do' do
    it 'downloads while the permission lasts, sees when it ends, and not after' do
      Permission.create!(datatable:, user: reader, granted_by: admin, expires_on: Date.current + 10)
      sign_in reader

      get datatable_path(datatable)
      ends_on = (Date.current + 10).to_fs(:long)
      expect(response.body).to include("Your permission to download this datatable ends on #{ends_on}")

      get datatable_path(datatable, format: :csv)
      expect(response).to have_http_status(:ok)

      travel(11.days) do
        reset! # a fresh session: the old one has passed its idle timeout
        sign_in reader
        get datatable_path(datatable, format: :csv)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
