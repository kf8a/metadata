# frozen_string_literal: true

require 'rails_helper'

# Devise's paranoid mode makes the password reset form answer alike for an email that has an account and
# one that has not, so it cannot be used to find out who has an account.
RSpec.describe 'Requesting a password reset', type: :request do
  before do
    Website.create!(name: 'lter', url: 'lter.kbs.msu.edu')
    FactoryBot.create(:user, email: 'member@example.com')
  end

  def request_reset_for(email)
    post user_password_path, params: { user: { email: } }
    [response.status, response.location, flash[:notice], flash[:alert]]
  end

  it 'answers an unknown email exactly as it answers a known one' do
    expect(request_reset_for('nobody@example.com')).to eq request_reset_for('member@example.com')
  end

  it 'says only that instructions are sent if the email has an account' do
    _status, _location, notice, alert = request_reset_for('nobody@example.com')

    expect(notice).to include('If your email address exists in our database')
    expect(alert).to be_nil
  end

  it 'sends the email only to an address that has an account' do
    expect { request_reset_for('nobody@example.com') }.not_to(change { ActionMailer::Base.deliveries.count })
    expect { request_reset_for('member@example.com') }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
