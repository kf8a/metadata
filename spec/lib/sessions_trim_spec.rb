# frozen_string_literal: true

require 'rails_helper'
require 'rake'

RSpec.describe 'sessions:trim' do
  before(:all) { Rails.application.load_tasks unless Rake::Task.task_defined?('sessions:trim') }

  def make_session(id, updated_at)
    ActiveRecord::SessionStore::Session.create!(session_id: id, data: {}, updated_at:)
  end

  it 'deletes sessions idle for longer than the sign-in timeout plus a day, and keeps the rest' do
    make_session('expired', (Devise.timeout_in + 2.days).ago)
    make_session('just-timed-out', (Devise.timeout_in + 1.hour).ago)
    make_session('active', 1.hour.ago)

    Rake::Task['sessions:trim'].reenable
    Rake::Task['sessions:trim'].invoke

    expect(ActiveRecord::SessionStore::Session.pluck(:session_id)).to contain_exactly('just-timed-out', 'active')
  end
end
