# frozen_string_literal: true

require 'rails_helper'

# Form params go through params.expect, which wants nested records as arrays
# of hashes ([[...]]) and answers a malformed request with 400 instead of 500.
RSpec.describe 'Strong parameters', type: :request do
  include Devise::Test::IntegrationHelpers

  before do
    Website.create!(name: 'lter', url: 'lter.kbs.msu.edu')
    sign_in FactoryBot.create(:admin_user)
  end

  it 'saves nested affiliations posted by fields_for' do
    person = FactoryBot.create(:person)
    role = FactoryBot.create(:role)

    patch person_path(person), params: {
      person: { given_name: 'Jo', affiliations_attributes: { '0' => { role_id: role.id, title: 'Director' } } }
    }

    expect(person.reload.given_name).to eq 'Jo'
    expect(person.affiliations.map(&:title)).to eq ['Director']
  end

  it 'saves nested variates posted by fields_for' do
    datatable = FactoryBot.create(:datatable)

    patch datatable_path(datatable), params: {
      datatable: {
        title: 'Renamed', variates_attributes: { '0' => { name: 'sample_date', description: 'date sampled' } }
      }
    }

    expect(datatable.reload.title).to eq 'Renamed'
    expect(datatable.variates.map(&:name)).to include('sample_date')
  end

  it 'answers a malformed form with 400' do
    person = FactoryBot.create(:person)

    patch person_path(person), params: { person: 'not a hash' }

    expect(response).to have_http_status(:bad_request)
  end

  it 'answers a missing form with 400' do
    patch project_path(Project.create!(title: 'A project'))

    expect(response).to have_http_status(:bad_request)
  end
end
