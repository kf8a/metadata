# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GlbrcGroupLookup do
  it "returns the groups recorded at the user's last GLBRC sign-in" do
    user = FactoryBot.create(:user, last_glbrc_groups: %w[group-a group-b])

    expect(described_class.call(user)).to eq %w[group-a group-b]
  end

  it 'returns no groups for a user who has never signed in through GLBRC' do
    expect(described_class.call(FactoryBot.create(:user))).to eq []
  end
end
