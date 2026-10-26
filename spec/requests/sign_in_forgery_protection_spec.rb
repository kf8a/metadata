# frozen_string_literal: true

require 'rails_helper'

# Signing in is checked for forgery like every other form: a sign-in posted from
# another site, without the form's token, could log a visitor into an attacker's account.
RSpec.describe 'Signing in with forgery protection', type: :request do
  around do |example|
    ActionController::Base.allow_forgery_protection = true
    example.run
  ensure
    ActionController::Base.allow_forgery_protection = false
  end

  before do
    Website.create!(name: 'lter', url: 'lter.kbs.msu.edu')
    FactoryBot.create(:user, email: 'member@example.com', password: 'a-long-test-password')
  end

  let(:credentials) { { email: 'member@example.com', password: 'a-long-test-password' } }

  def form_token
    get new_user_session_path
    response.parsed_body.at('form input[name="authenticity_token"]')['value']
  end

  it 'signs in with the token from the sign-in form' do
    post user_session_path, params: { authenticity_token: form_token, user: credentials }

    expect(response).to redirect_to(root_path)
  end

  # The credentials are right, so only the forgery check can stop the redirect
  it 'rejects a sign-in without a token' do
    post user_session_path, params: { user: credentials }

    expect(response).to have_http_status(:unprocessable_content)
  end

  it 'rejects a sign-in posted from another site' do
    token = form_token

    post user_session_path, params: { authenticity_token: token, user: credentials },
                            headers: { 'Origin' => 'https://attacker.example' }

    expect(response).to have_http_status(:unprocessable_content)
  end
end
