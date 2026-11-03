# frozen_string_literal: true

require 'rails_helper'

# A visualization's JSON is its datatable's rows, so it follows the datatable's CSV download rules.
RSpec.describe 'Visualization data permissions', type: :request do
  include Devise::Test::IntegrationHelpers

  before { Website.create!(name: 'lter', url: 'lter.kbs.msu.edu') }

  def get_data(visualization)
    get visualization_path(visualization, format: :json)
  end

  it 'serves a visualization without a datatable to anyone' do
    get_data(FactoryBot.create(:visualization))

    expect(response).to have_http_status(:ok)
  end

  it 'serves an open datatable\'s visualization to anyone' do
    get_data(FactoryBot.create(:visualization, datatable: FactoryBot.create(:datatable)))

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body).to eq [{ 'sample_date' => 1 }]
  end

  describe 'a restricted datatable' do
    let(:datatable) { FactoryBot.create(:datatable, is_restricted: true) }
    let(:visualization) { FactoryBot.create(:visualization, datatable:) }

    it 'refuses visitors without sending the data' do
      get_data(visualization)

      expect(response).to have_http_status(:forbidden)
      expect(response.body).to be_empty
    end

    it 'refuses a signed-in user without permission' do
      sign_in FactoryBot.create(:user)
      get_data(visualization)

      expect(response).to have_http_status(:forbidden)
    end

    it 'serves the owner' do
      owner = FactoryBot.create(:user)
      Ownership.create!(user: owner, datatable:)
      sign_in owner
      get_data(visualization)

      expect(response).to have_http_status(:ok)
    end

    it 'serves an admin' do
      sign_in FactoryBot.create(:admin_user)
      get_data(visualization)

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'a members-only datatable' do
    let(:datatable) { FactoryBot.create(:datatable, dataset: FactoryBot.create(:restricted_dataset)) }
    let(:visualization) { FactoryBot.create(:visualization, datatable:) }

    it 'refuses visitors' do
      get_data(visualization)

      expect(response).to have_http_status(:forbidden)
    end

    it 'serves a member of the sponsor' do
      member = FactoryBot.create(:user)
      Membership.create!(user: member, sponsor: datatable.dataset.sponsor)
      sign_in member
      get_data(visualization)

      expect(response).to have_http_status(:ok)
    end
  end
end
