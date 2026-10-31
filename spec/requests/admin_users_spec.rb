# frozen_string_literal: true

require 'rails_helper'

# Admins add, edit and remove users and their memberships.
RSpec.describe 'Managing users', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:admin) { FactoryBot.create(:admin_user, email: 'admin@example.org') }
  let(:glbrc) { Sponsor.create!(name: 'glbrc') }
  let(:lter) { Sponsor.create!(name: 'lter') }
  let(:details) { { email: 'New.Person@example.org', first_name: 'Ada', last_name: 'Reader', institution: 'MSU' } }

  before do
    ActionMailer::Base.deliveries.clear
    sign_in admin
  end

  def mails
    ActionMailer::Base.deliveries
  end

  it 'turns away someone who is not an admin' do
    sign_in FactoryBot.create(:user)

    get admin_users_path
    expect(response).to redirect_to(new_user_session_path)
  end

  it 'lists users, and finds them by name' do
    FactoryBot.create(:user, email: 'someone@example.org', first_name: 'Grace', sponsors: [glbrc])

    get admin_users_path(q: 'grace')
    expect(response.body).to include('someone@example.org', 'glbrc')
    expect(response.body).not_to include('admin@example.org</a>')
  end

  it 'adds a user with memberships and emails them a link to set a password, on the site it was added from' do
    host! 'data.sustainability.glbrc.org'
    post admin_users_path, params: { user: details.merge(role: '', sponsor_ids: ['', glbrc.id]) }

    user = User.find_by!(email: 'new.person@example.org')
    expect(user).to have_attributes(first_name: 'Ada', role: nil, sponsors: [glbrc])
    expect(user.invitation_pending?).to be true
    expect(mails.size).to eq 1
    expect(mails.last.reply_to).to eq ['admin@example.org']
    expect(mails.last.body.to_s).to include('https://data.sustainability.glbrc.org/users/invitation/accept',
                                            'sign in with your GLBRC account')
  end

  it 'asks again, and creates nothing, without a name and institution' do
    post admin_users_path, params: { user: { email: 'new.person@example.org' } }

    expect(response).to have_http_status(:unprocessable_content)
    expect(User.exists?(email: 'new.person@example.org')).to be false
    expect(mails).to be_empty
  end

  it 'changes details, role and memberships' do
    user = FactoryBot.create(:user, sponsors: [glbrc])

    patch admin_user_path(user), params: { user: { institution: 'GLBRC', role: 'editor', sponsor_ids: ['', lter.id] } }

    expect(user.reload).to have_attributes(institution: 'GLBRC', role: 'editor', sponsors: [lter])
  end

  it 'removes all memberships when none are ticked' do
    user = FactoryBot.create(:user, sponsors: [glbrc])

    patch admin_user_path(user), params: { user: { sponsor_ids: [''] } }

    expect(user.reload.sponsors).to be_empty
  end

  it "won't take the admin role from your own account" do
    patch admin_user_path(admin), params: { user: { role: '' } }

    expect(response).to have_http_status(:unprocessable_content)
    expect(admin.reload.role).to eq 'admin'
  end

  it 'removes a user with their permissions, but not your own account' do
    user = FactoryBot.create(:user)
    Permission.create!(datatable: FactoryBot.create(:datatable), user:, granted_by: admin)

    delete admin_user_path(user)
    delete admin_user_path(admin)

    expect(User.all).to contain_exactly(admin)
    expect(Permission.count).to eq 0
  end

  it 'sends a fresh link to someone who has not set a password yet' do
    post admin_users_path, params: { user: details }
    user = User.find_by!(email: 'new.person@example.org')

    post resend_invitation_admin_user_path(user)

    expect(mails.size).to eq 2
    expect(mails.map { |mail| mail.body.to_s[/invitation_token=\S+/] }.uniq.size).to eq 2
  end
end
