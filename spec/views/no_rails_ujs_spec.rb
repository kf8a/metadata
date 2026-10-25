# frozen_string_literal: true

require 'rails_helper'

# rails-ujs and the old jQuery plugins are not loaded, so their options and hooks
# render attributes nothing acts on. Use data: { turbo_method:, turbo_confirm: }
# (or form: { data: { turbo_confirm: } } on button_to) and Stimulus controllers.
RSpec.describe 'view templates' do
  templates = Rails.root.glob('app/views/**/*.erb').reject { |path| path.to_s.include?('/datum/') }
  relative = ->(path) { path.relative_path_from(Rails.root).to_s }

  it 'do not use rails-ujs options' do
    offenders = templates.flat_map do |path|
      source = path.read
      calls = source.scan(/<%=\s*link_to\b.*?%>/m).grep(/(?<!turbo_)method:|:method\s*=>/)
      options = source.scan(/(?<!turbo_)confirm:|:confirm\s*=>|disable_with|data-confirm|data-method|remote:\s*true/)
      (calls + options).map { |hit| "#{relative.call(path)}: #{hit.squish.truncate(80)}" }
    end

    expect(offenders).to be_empty
  end

  it 'do not use hooks for the removed jQuery plugins' do
    hooks = /myselect|class: *'deleter'|'truncate'|link_to_function|remove_fields\(|quickTree|collapsable|clearit/
    offenders = templates.select { |path| path.read.match?(hooks) }
                         .map(&relative)
                         .reject { |path| path.end_with?('lter_index_not_used.html.erb') }

    expect(offenders).to be_empty
  end
end
