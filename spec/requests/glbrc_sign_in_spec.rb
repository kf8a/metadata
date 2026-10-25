# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'GLBRC sign-in callback', type: :request do
  before do
    Website.create!(name: 'lter', url: 'lter.kbs.msu.edu')
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:glbrc] = OmniAuth::AuthHash.new(
      provider: 'glbrc',
      uid: 'uid-123',
      credentials: { token: 'secret-access-token', refresh_token: 'secret-refresh-token' },
      info: { id_token: { email: 'new.user@glbrc.org', groups: [] } }
    )
  end

  after do
    OmniAuth.config.mock_auth[:glbrc] = nil
    OmniAuth.config.test_mode = false
  end

  it 'signs a new user in' do
    get user_glbrc_omniauth_callback_path

    expect(response).to be_redirect
    expect(User.find_by(email: 'new.user@glbrc.org')).to be_present
  end

  it 'does not keep the provider response in the session when access is refused' do
    allow(User).to receive(:from_omniauth).and_return(nil)

    get user_glbrc_omniauth_callback_path

    expect(response).to redirect_to('/')
    expect(session.to_h.keys).not_to include('devise.glbrc_data')
    expect(session.to_h.to_s).not_to include('secret-access-token')
  end
end
