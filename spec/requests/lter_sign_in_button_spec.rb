# frozen_string_literal: true

require 'rails_helper'

# The LTER layout ends with the same sign in/out partial the GLBRC layout starts with.
RSpec.describe 'Sign in/out button on the LTER layout', type: :request do
  include Devise::Test::IntegrationHelpers

  before { Website.create!(name: 'lter', url: 'lter.kbs.msu.edu') }

  def button
    response.parsed_body.at('body > #sign-in-wrapper #sign-in a')
  end

  it 'offers Sign In to visitors, after the page content' do
    get datatables_path

    expect(button.text).to eq 'Sign In'
    expect(button['href']).to end_with(new_user_session_path)
    ids = response.parsed_body.at('body').element_children.pluck('id')
    expect(ids.index('sign-in-wrapper')).to be > ids.index('wrap')
  end

  it 'offers Sign Out to signed-in users as a Turbo DELETE' do
    sign_in FactoryBot.create(:user)

    get datatables_path

    expect(button.text).to eq 'Sign Out'
    expect(button['href']).to end_with(destroy_user_session_path)
    expect(button['data-turbo-method']).to eq 'delete'
  end

  it 'signs out and lands on the page with a notice' do
    sign_in FactoryBot.create(:user)

    delete destroy_user_session_path

    expect(response).to have_http_status(:see_other)
    follow_redirect!
    expect(response.parsed_body.at('body > #sign-in-wrapper #sign-in a').text).to eq 'Sign In'
  end
end
