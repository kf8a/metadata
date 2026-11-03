# frozen_string_literal: true

require 'rails_helper'

# Signed-in members are signed out after 4 hours without a request and admins after 2 days.
# "Remember me" signs them back in from a cookie that lasts a week from sign-in, whatever they do in between.
RSpec.describe 'Session timeout', type: :request do
  include ActiveSupport::Testing::TimeHelpers

  before do
    Website.create!(name: 'lter', url: 'lter.kbs.msu.edu')
    FactoryBot.create(:user, email: 'member@example.com', password: 'a-long-test-password')
    FactoryBot.create(:admin_user, email: 'admin@example.com', password: 'a-long-test-password')
  end

  def sign_in_with(email = 'member@example.com', remember: false)
    post user_session_path,
         params: { user: { email:, password: 'a-long-test-password', remember_me: remember ? '1' : '0' } }
  end

  def signed_in_after?(time_passed)
    travel(time_passed)
    get datatables_path
    follow_redirect! if response.redirect?
    response.parsed_body.at('#sign-in a').text == 'Sign Out'
  end

  it 'keeps a member signed in through 3 hours of inactivity' do
    sign_in_with

    expect(signed_in_after?(3.hours)).to be true
  end

  it 'signs a member out after 5 hours of inactivity and says why' do
    sign_in_with

    expect(signed_in_after?(5.hours)).to be false
    expect(response.body).to include('Your session expired')
  end

  it 'keeps an admin signed in through 47 hours of inactivity' do
    sign_in_with('admin@example.com')

    expect(signed_in_after?(47.hours)).to be true
  end

  it 'signs an admin out after 49 hours of inactivity' do
    sign_in_with('admin@example.com')

    expect(signed_in_after?(49.hours)).to be false
  end

  it 'counts each request as activity' do
    sign_in_with

    3.times { expect(signed_in_after?(3.hours)).to be true }
  end

  it 'signs a remembered member back in after the inactivity timeout' do
    sign_in_with(remember: true)

    expect(signed_in_after?(5.hours)).to be true
  end

  it 'forgets a remembered member after a week' do
    sign_in_with(remember: true)

    expect(signed_in_after?(6.days)).to be true
    expect(signed_in_after?(2.days)).to be false
  end
end
