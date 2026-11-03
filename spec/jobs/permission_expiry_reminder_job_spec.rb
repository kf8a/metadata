# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PermissionExpiryReminderJob do
  let(:website) { Website.find_by(name: 'lter') || Website.create!(name: 'lter', url: 'lter.kbs.msu.edu') }
  let(:datatable) do
    FactoryBot.create(:datatable, is_restricted: true, dataset: FactoryBot.create(:dataset, website:))
  end
  let(:admin) { FactoryBot.create(:admin_user, email: 'admin@example.org') }

  before { ActionMailer::Base.deliveries.clear }

  def grant(email, expires_on)
    Permission.create!(datatable:, user: FactoryBot.create(:user, email:), granted_by: admin, expires_on:)
  end

  def sent_to
    ActionMailer::Base.deliveries.flat_map(&:to)
  end

  it 'emails once, a week before access ends, and nobody whose access ends later, never or already has' do
    grant('soon@example.org', Date.current + 7)
    grant('later@example.org', Date.current + 8)
    grant('never@example.org', nil)
    grant('expired@example.org', Date.current - 1)

    2.times { described_class.perform_now }

    expect(sent_to).to eq ['soon@example.org']
    mail = ActionMailer::Base.deliveries.last
    expect(mail.subject).to eq "Your access to #{datatable.name} ends on #{(Date.current + 7).to_fs(:long)}"
    expect(mail.reply_to).to eq ['admin@example.org']
    expect(mail.body.to_s).to include("https://lter.kbs.msu.edu/datatables/#{datatable.id}")
  end

  it 'reminds again for the new end date after the permission is extended' do
    permission = grant('soon@example.org', Date.current + 3)
    described_class.perform_now

    permission.reload.update!(expires_on: Date.current + 6)
    described_class.perform_now

    expect(sent_to).to eq ['soon@example.org', 'soon@example.org']
  end

  it 'links to the site the permission was granted from' do
    grant('soon@example.org', Date.current + 7).update!(site: 'glbrc')

    described_class.perform_now

    expect(ActionMailer::Base.deliveries.last.body.to_s)
      .to include("https://data.sustainability.glbrc.org/datatables/#{datatable.id}")
  end
end
