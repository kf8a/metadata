# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsTrimJob do
  def make_session(id, updated_at)
    ActiveRecord::SessionStore::Session.create!(session_id: id, data: {}, updated_at:)
  end

  it 'deletes sessions idle past the longest timeout plus a day, and keeps the rest' do
    make_session('expired', (Devise.timeout_in + 2.days).ago)
    make_session('just-timed-out', (Devise.timeout_in + 1.hour).ago)
    make_session('active', 1.hour.ago)

    described_class.perform_now

    expect(ActiveRecord::SessionStore::Session.pluck(:session_id)).to contain_exactly('just-timed-out', 'active')
  end

  it 'never deletes an admin session that is still within its timeout' do
    admin_timeout = FactoryBot.build(:admin_user).timeout_in
    make_session('admin-idle', (admin_timeout - 1.hour).ago)

    described_class.perform_now

    expect(ActiveRecord::SessionStore::Session.pluck(:session_id)).to eq ['admin-idle']
  end

  it 'is enqueued on the default queue' do
    expect { described_class.perform_later }.to have_enqueued_job(described_class).on_queue('default')
  end
end
