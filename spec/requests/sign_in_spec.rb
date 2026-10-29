# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Signing in with a password', type: :request do
  before do
    Website.create!(name: 'lter', url: 'lter.kbs.msu.edu')
    @user = FactoryBot.create(:user, email: 'member@example.com', password: 'a-long-test-password')
  end

  def sign_in_with(password)
    post user_session_path, params: { user: { email: 'member@example.com', password: password } }
  end

  it 'signs in with the right password' do
    sign_in_with('a-long-test-password')

    expect(response).to redirect_to(root_path)
  end

  # Devise's paranoid mode answers every failed sign-in alike, so the form cannot be used to find out
  # which emails have an account or which accounts are locked.
  it 'rejects the right password once the account is locked, without saying it is locked' do
    10.times { sign_in_with('wrong-password') }
    expect(@user.reload).to be_access_locked

    sign_in_with('a-long-test-password')
    expect(response).not_to be_redirect
    expect(flash[:alert]).to eq 'Invalid email or password.'
  end

  it 'emails unlock instructions when the account locks' do
    expect { 10.times { sign_in_with('wrong-password') } }
      .to change { ActionMailer::Base.deliveries.count }.by(1)
    expect(ActionMailer::Base.deliveries.last.subject).to eq 'Unlock instructions'
  end
end
