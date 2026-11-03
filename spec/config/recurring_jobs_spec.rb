# frozen_string_literal: true

require 'rails_helper'

# config/recurring.yml is read by Solid Queue's scheduler in bin/jobs; a typo there fails
# quietly in production. Validate each entry with Solid Queue's own checks: a schedule it can
# parse, and a command or a class that is an Active Job.
RSpec.describe 'config/recurring.yml' do
  let(:tasks) do
    YAML.load(ERB.new(Rails.root.join('config/recurring.yml').read).result, aliases: true).fetch('production')
  end

  it 'schedules the daily session trim' do
    expect(tasks.dig('sessions_trim', 'class')).to eq 'SessionsTrimJob'
  end

  it 'has only entries Solid Queue accepts' do
    tasks.each do |key, options|
      task = SolidQueue::RecurringTask.from_configuration(key, **options.symbolize_keys)
      valid = task.valid?

      expect(valid).to be(true), "#{key}: #{task.errors.full_messages.to_sentence}"
    end
  end
end
