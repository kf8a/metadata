# frozen_string_literal: true

require 'rails_helper'

# rails-ujs is not loaded, so its options render attributes nothing acts on.
# Use data: { turbo_method:, turbo_confirm: } (or form: { data: { turbo_confirm: } } on button_to).
RSpec.describe 'view templates' do
  templates = Dir[Rails.root.join('app/views/**/*.erb')].reject { |path| path.include?('/datum/') }

  it 'do not use rails-ujs options' do
    offenders = templates.flat_map do |path|
      source = File.read(path)
      calls = source.scan(/<%=\s*link_to\b.*?%>/m).select { |call| call.match?(/(?<!turbo_)method:|:method\s*=>/) }
      options = source.scan(/(?<!turbo_)confirm:|:confirm\s*=>|disable_with|data-confirm|data-method|remote:\s*true/)
      (calls + options).map { |hit| "#{path.delete_prefix("#{Rails.root}/")}: #{hit.squish.truncate(80)}" }
    end

    expect(offenders).to be_empty
  end
end
