# frozen_string_literal: true

require 'rails_helper'

# Signed-in users are signed out after 24 hours without a request. "Remember me" signs them
# back in from a cookie that lasts a week from sign-in, whatever they do in between.
RSpec.describe 'Session timeout', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  before do
    Website.create!(name: 'lter', url: 'lter.kbs.msu.edu')
    FactoryBot.create(:user, email: 'member@example.com', password: 'a-long-test-password')
  end

  def sign_in_with(remember: false)
    post user_session_path,
         params: { user: { email: 'member@example.com', password: 'a-long-test-password',
                           remember_me: remember ? '1' : '0' } }
  end

  def signed_in_after?(time_passed)
    travel(time_passed)
    get datatables_path
    follow_redirect! if response.redirect?
    response.parsed_body.at('#sign-in a').text == 'Sign Out'
  end

  it 'keeps a user signed in through 23 hours of inactivity' do
    sign_in_with

    expect(signed_in_after?(23.hours)).to be true
  end

  it 'signs a user out after 25 hours of inactivity and says why' do
    sign_in_with

    expect(signed_in_after?(25.hours)).to be false
    expect(response.body).to include('Your session expired')
  end

  it 'counts each request as activity' do
    sign_in_with

    3.times { expect(signed_in_after?(23.hours)).to be true }
  end

  it 'signs a remembered user back in after the inactivity timeout' do
    sign_in_with(remember: true)

    expect(signed_in_after?(25.hours)).to be true
  end

  it 'forgets a remembered user after a week' do
    sign_in_with(remember: true)

    expect(signed_in_after?(6.days)).to be true
    expect(signed_in_after?(2.days)).to be false
  end
end
