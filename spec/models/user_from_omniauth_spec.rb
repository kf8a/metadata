# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, '.from_omniauth' do
  before do
    @glbrc = Sponsor.create!(name: 'glbrc')
  end

  def auth(email: 'new.user@glbrc.org', groups: [])
    OmniAuth::AuthHash.new(
      provider: 'glbrc',
      uid: 'uid-123',
      credentials: { token: 'secret-access-token', refresh_token: 'secret-refresh-token' },
      info: { id_token: { email: email, groups: groups } }
    )
  end

  it 'gives a new user in an allowed group the glbrc sponsor' do
    user = User.from_omniauth(auth(groups: ['other-group', 'glbrc.org\AIM-InformationServices']))

    expect(user).to be_persisted
    expect(user.sponsors).to eq [@glbrc]
  end

  it 'matches the allowed group whose name contains spaces' do
    group = 'glbrc.org/GLBRC/GLBRC Groups/Y16-20/Sustainable_Bioenergy_Cropping_Systems/SEP'
    user = User.from_omniauth(auth(groups: [group]))

    expect(user.sponsors).to eq [@glbrc]
  end

  it 'gives a new user in the SEP group the glbrc sponsor' do
    user = User.from_omniauth(auth(groups: ['glbrc.org\SEP']))

    expect(user.sponsors).to eq [@glbrc]
  end

  it "records a new user's groups" do
    user = User.from_omniauth(auth(groups: %w[group-a group-b]))

    expect(user.reload.last_glbrc_groups).to eq %w[group-a group-b]
  end

  it "updates an existing user's groups and keeps them when a later token has none" do
    existing = FactoryBot.create(:user, email: 'old.user@glbrc.org')
    User.from_omniauth(auth(email: 'old.user@glbrc.org', groups: %w[group-a]))
    expect(existing.reload.last_glbrc_groups).to eq %w[group-a]

    User.from_omniauth(auth(email: 'old.user@glbrc.org', groups: nil))
    expect(existing.reload.last_glbrc_groups).to eq %w[group-a]
  end

  it 'creates a new user outside the allowed groups without the sponsor' do
    user = User.from_omniauth(auth(groups: ['other-group']))

    expect(user).to be_persisted
    expect(user.sponsors).to be_empty
  end

  it 'creates the user when the token has no groups' do
    user = User.from_omniauth(auth(groups: nil))

    expect(user).to be_persisted
    expect(user.sponsors).to be_empty
  end

  it 'does not write the identity provider response, tokens included, to the log' do
    log = StringIO.new
    allow(User).to receive(:logger).and_return(Logger.new(log))

    User.from_omniauth(auth(groups: ['glbrc.org\AIM-InformationServices']))
    User.from_omniauth(auth(email: 'new.user@glbrc.org'))

    expect(log.string).not_to include('secret-access-token')
    expect(log.string).not_to include('secret-refresh-token')
    expect(log.string).not_to include('AIM-InformationServices')
  end

  it 'links an existing user by email without changing their sponsors' do
    existing = FactoryBot.create(:user, email: 'old.user@glbrc.org')
    User.from_omniauth(auth(email: 'old.user@glbrc.org', groups: ['glbrc.org\AIM-InformationServices']))

    existing.reload
    expect(existing.uid).to eq 'uid-123'
    expect(existing.sponsors).to be_empty
  end
end
