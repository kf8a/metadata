# frozen_string_literal: true

require 'rails_helper'

# Restricted CSVs and citation PDFs are handed out through an Active Storage redirect link. Its default
# form never expires, so anyone who had seen it once could download without signing in. The link now
# expires after a minute; the sign-in and permission checks in front of it are unchanged.
RSpec.describe 'Links to protected files', type: :request do
  include Devise::Test::IntegrationHelpers
  include ActiveSupport::Testing::TimeHelpers

  before { Website.create!(name: 'lter', url: 'lter.kbs.msu.edu') }

  def citation_with_pdf(open_access:)
    citation = ArticleCitation.new(title: 'A paper', pub_year: 2020, state: 'published',
                                   website: Website.find_by!(name: 'lter'), open_access:)
    citation.authors.build(sur_name: 'Smith', given_name: 'Jo', seniority: 1)
    citation.save!
    citation.pdf.attach(io: StringIO.new('%PDF-1.4'), filename: 'paper.pdf', content_type: 'application/pdf')
    citation
  end

  # Follows the link the way someone who only has the link would: with no session
  def follow_link_without_session(link)
    reset!
    get link
  end

  def link
    URI(response.location).request_uri
  end

  describe 'citation PDFs' do
    it 'hands a signed-in user a link that works right away, without a session' do
      sign_in FactoryBot.create(:user)
      get download_citation_path(citation_with_pdf(open_access: false))

      expect(link).to start_with('/rails/active_storage/blobs/redirect/')
      follow_link_without_session(link)
      expect(response).to have_http_status(:found)
      expect(response.location).to include('/rails/active_storage/disk/')
    end

    it 'stops the link working after two minutes' do
      sign_in FactoryBot.create(:user)
      get download_citation_path(citation_with_pdf(open_access: false))
      url = link

      travel(2.minutes) { follow_link_without_session(url) }

      expect(response).to have_http_status(:not_found)
    end

    it 'also expires the link for an open-access paper' do
      get download_citation_path(citation_with_pdf(open_access: true))
      url = link

      travel(2.minutes) { follow_link_without_session(url) }

      expect(response).to have_http_status(:not_found)
    end

    it 'still sends a visitor to sign in for a paper that is not open access' do
      get download_citation_path(citation_with_pdf(open_access: false))

      expect(response).to redirect_to(new_user_session_url)
    end
  end

  describe 'restricted datatable CSVs' do
    let(:datatable) { FactoryBot.create(:datatable, is_restricted: true) }
    let(:owner) { FactoryBot.create(:user) }

    before do
      Ownership.create!(user: owner, datatable:)
      datatable.csv_file.attach(io: StringIO.new("a,b\n1,2\n"), filename: 'data.csv', content_type: 'text/csv')
    end

    it 'hands an owner a link that works right away and stops working after two minutes' do
      sign_in owner
      get datatable_path(datatable, format: :csv)
      url = link

      expect(url).to start_with('/rails/active_storage/blobs/redirect/')
      follow_link_without_session(url)
      expect(response).to have_http_status(:found)

      travel(2.minutes) { follow_link_without_session(url) }
      expect(response).to have_http_status(:not_found)
    end

    it 'still refuses a signed-in user who has no permission' do
      sign_in FactoryBot.create(:user)
      get datatable_path(datatable, format: :csv)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
