# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Rails.application.config.filter_parameters' do
  let(:filter) { ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters) }

  it 'masks passwords, tokens, secrets and email addresses' do
    filtered = filter.filter(
      'user' => { 'email' => 'a@example.org', 'password' => 'pw-value', 'password_confirmation' => 'pw-value' },
      'authenticity_token' => 'csrf-token',
      'reset_password_token' => 'reset-token',
      'unlock_token' => 'unlock-token',
      'omniauth' => { 'credentials' => { 'token' => 'access-value', 'refresh_token' => 'refresh-value' },
                    'client_secret' => 'sec-value' }
    )

    expect(filtered.to_s).not_to match(/a@example\.org|pw-value|csrf-token|reset-token|unlock-token|access-value|refresh-value|sec-value/)
  end

  it 'leaves ordinary parameters readable' do
    params = { 'q' => 'soil carbon', 'id' => '12', 'type' => 'ArticleCitation' }

    expect(filter.filter(params)).to eq params
  end
end
