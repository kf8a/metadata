# frozen_string_literal: true

require 'rails_helper'

# The jQuery plugins these pages used are gone; check the markup now drives
# Stimulus controllers or plain HTML instead.
RSpec.describe 'Pages without the legacy jQuery plugins', type: :request do
  include Devise::Test::IntegrationHelpers

  before { Website.create!(name: 'lter', url: 'lter.kbs.msu.edu') }

  def page
    response.parsed_body
  end

  it 'offers search suggestions through a datalist' do
    get datatables_path

    input = page.at('#keyworder')
    expect(input['list']).to eq 'keyword-suggestions'
    expect(input['value']).to be_nil
    expect(page.at('[data-controller="autocomplete"]')['data-autocomplete-url-value']).to eq suggest_datatables_path
    expect(page.at('datalist#keyword-suggestions')).to be_present
  end

  it 'renders the data catalog tree for the Stimulus controller' do
    get datatables_path

    tree = page.at('[data-controller="tree"]')
    expect(tree.at('ul.tree[data-tree-target="list"]')).to be_present
    expect(tree.at('a[data-action="tree#toggleAll"][data-tree-target="toggleAll"]')).to be_present
  end

  it 'marks the body for signed-in users only, outside any cached fragment' do
    get datatables_path
    expect(page.at('body')['class'].to_s.split).not_to include('signed-in')

    sign_in FactoryBot.create(:user)
    get datatables_path
    expect(page.at('body')['class'].split).to include('signed-in')
  end

  it 'decodes person emails with a Stimulus controller' do
    person = FactoryBot.create(:person, email: 'jane@example.org')

    get person_path(person)

    item = page.at('li.person-email[data-controller="obfuscated-email"]')
    expect(item.text.strip).to eq 'jane at example.org'
  end

  it 'renders nested-field links for the Stimulus controller' do
    sign_in FactoryBot.create(:admin_user)
    datatable = FactoryBot.create(:datatable)

    get edit_datatable_path(datatable)

    add = page.at('a[data-action="nested-fields#add"][data-nested-fields-container-value="#variates"]')
    expect(add).to be_present
    template = add['data-nested-fields-template-value']
    expect(template).to include(add['data-nested-fields-placeholder-value'])
    expect(template).to include('data-action="nested-fields#remove"')
    expect(page.at('a[onclick]')).to be_nil
  end
end
