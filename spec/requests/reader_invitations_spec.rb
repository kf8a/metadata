# frozen_string_literal: true

require 'rails_helper'

# An admin granting access to an email without an account creates the account; the person sets a password
# from the emailed link and can then download.
RSpec.describe 'Granting access to someone without an account', type: :request do
  include Devise::Test::IntegrationHelpers
  include ActiveSupport::Testing::TimeHelpers

  let(:website) { Website.find_by(name: 'lter') || Website.create!(name: 'lter', url: 'lter.kbs.msu.edu') }
  let(:datatable) do
    FactoryBot.create(:datatable, is_restricted: true, dataset: FactoryBot.create(:dataset, website:),
                                  object: "select '2020-01-01'::date as sample_date")
  end
  let(:admin) { FactoryBot.create(:admin_user, email: 'admin@example.org') }
  let(:details) { { first_name: 'Ada', last_name: 'Reader', institution: 'Michigan State University' } }

  before do
    ActionMailer::Base.deliveries.clear
    sign_in admin
  end

  def grant(params = {}, table: datatable)
    post permissions_path, params: { datatable: table.id, email: 'New.Reader@example.org ' }.merge(params)
  end

  def mails
    ActionMailer::Base.deliveries
  end

  def link_in(mail)
    URI(mail.body.to_s[%r{https://\S+/users/invitation/accept\?invitation_token=\S+}])
  end

  it 'asks for the name and institution first, and creates nothing' do
    grant

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('No account has the email new.reader@example.org', 'First name', 'Institution')
    expect(User.exists?(email: 'new.reader@example.org')).to be false
    expect(mails).to be_empty
  end

  it 'creates the account and the permission, and sends one email with a link to set a password' do
    grant(details.merge(intended_use: 'Thesis chapter on soil carbon'))

    reader = User.find_by!(email: 'new.reader@example.org')
    expect(reader).to have_attributes(details)
    expect(datatable.permission_for(reader).intended_use).to eq 'Thesis chapter on soil carbon'
    expect(mails.size).to eq 1
    expect(mails.last.subject).to eq "An account to download #{datatable.name}"
    expect(link_in(mails.last).to_s).to start_with('https://lter.kbs.msu.edu/users/invitation/accept')
    expect(mails.last.body.to_s).not_to include('GLBRC account')
  end

  it 'lets the person set a password from the link and then download' do
    grant(details)
    link = link_in(mails.last)
    reset!

    get link.request_uri
    expect(response).to have_http_status(:ok)
    token = Rack::Utils.parse_query(link.query)['invitation_token']
    password = 'a-long-new-password'
    put user_invitation_path, params: { user: { invitation_token: token, password:, password_confirmation: password } }

    get datatable_path(datatable, format: :csv)
    expect(response).to have_http_status(:ok)
  end

  it 'stops the link working once it is older than two weeks' do
    grant(details)
    link = link_in(mails.last)
    reset!

    travel_to(15.days.from_now) { get link.request_uri }
    expect(response).to redirect_to(root_path)
  end

  it "forgets the invitation's email address when the account is deleted" do
    grant(details)

    User.find_by!(email: 'new.reader@example.org').destroy!
    expect(DeviseInvitable::Invitation.count).to eq 0
  end

  it 'sends a fresh link when access is granted again before the password is set' do
    grant(details)
    grant

    expect(mails.map(&:subject)).to eq ["An account to download #{datatable.name}"] * 2
    expect(link_in(mails.first)).not_to eq link_in(mails.last)
  end

  it 'mentions GLBRC sign-in for GLBRC data' do
    glbrc_dataset = FactoryBot.create(:dataset, website:, sponsor: Sponsor.create!(name: 'glbrc'))
    glbrc_table = FactoryBot.create(:datatable, is_restricted: true, dataset: glbrc_dataset)
    grant(details, table: glbrc_table)

    expect(mails.last.body.to_s).to include('sign in with your GLBRC account instead')
  end

  it "keeps devise_invitable's own pages for sending invitations closed" do
    get '/users/invitation/new'

    expect(response).to have_http_status(:not_found)
  end
end
