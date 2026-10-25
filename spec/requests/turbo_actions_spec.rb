# frozen_string_literal: true

require 'rails_helper'

# Requests shaped the way Turbo sends them: links with data-turbo-method are
# submitted as a POST carrying _method, with Turbo's Accept header.
RSpec.describe 'Turbo-driven actions', type: :request do
  include Devise::Test::IntegrationHelpers

  let(:turbo_headers) { { 'Accept' => 'text/vnd.turbo-stream.html, text/html, application/xhtml+xml' } }

  before { Website.create!(name: 'lter', url: 'lter.kbs.msu.edu') }

  describe 'signing out' do
    before { sign_in FactoryBot.create(:user) }

    it 'renders the sign-out link as a Turbo DELETE' do
      get datatables_path

      expect(response.body).to include('data-turbo-method="delete"')
      expect(response.body).not_to include('data-method=')
    end

    it 'signs the user out and redirects' do
      post destroy_user_session_path, params: { _method: 'delete' }, headers: turbo_headers

      expect(response).to have_http_status(:see_other)
      get new_project_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  it 'answers a failed sign-in with 422 so Turbo re-renders the form' do
    FactoryBot.create(:user, email: 'member@example.com')

    post user_session_path, params: { user: { email: 'member@example.com', password: 'wrong-password' } },
                            headers: turbo_headers

    expect(response).to have_http_status(:unprocessable_content)
    expect(response.body).to include('Forgot your password?')
    expect(flash[:alert]).to eq 'Invalid email or password.'
  end

  it 'destroys a record from a Turbo DELETE link' do
    sign_in FactoryBot.create(:admin_user)
    project = Project.create!(title: 'Old project')

    post project_path(project), params: { _method: 'delete' }, headers: turbo_headers

    expect(response).to redirect_to(projects_url)
    expect(Project.exists?(project.id)).to be false
  end
end
