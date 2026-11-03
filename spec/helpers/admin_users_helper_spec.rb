# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::UsersHelper do
  include ActiveSupport::Testing::TimeHelpers

  def length_for(created_at)
    travel_to(Time.zone.local(2026, 11, 1)) { helper.membership_length(User.new(created_at:)) }
  end

  it 'says how long an account has existed, in years once past one, else months' do
    expect(length_for(Time.zone.local(2026, 10, 20))).to eq 'under a month'
    expect(length_for(Time.zone.local(2026, 10, 1))).to eq '1 month'
    expect(length_for(Time.zone.local(2026, 5, 2))).to eq '5 months'
    expect(length_for(Time.zone.local(2025, 11, 1))).to eq '1 year'
    expect(length_for(Time.zone.local(2019, 3, 5))).to eq '7 years'
    expect(length_for(nil)).to be_nil
  end
end
