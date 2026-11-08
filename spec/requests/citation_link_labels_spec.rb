# frozen_string_literal: true

require 'rails_helper'

# Every citation on the publications page has links reading "abstract" and "pdf", so the links need
# labels that tell a screen reader user which citation each one belongs to. Membership is decided
# server-side (and cached with a membership key), so guests and members get different footers.
RSpec.describe 'Citation link labels', type: :request do
  include Devise::Test::IntegrationHelpers

  def citation(title, sur_name, pdf: false, open_access: false, data_url: nil)
    citation = ArticleCitation.create!(title:, pub_year: 2020, state: 'published', open_access:, data_url:,
                                       website: Website.find_by!(name: 'lter'),
                                       authors: [Author.new(sur_name:, given_name: 'Jo', seniority: 1)])
    citation.pdf.attach(io: StringIO.new('%PDF-1.4'), filename: 'paper.pdf', content_type: 'application/pdf') if pdf
    citation
  end

  def labels
    response.parsed_body.css('.citation-footer a').pluck('aria-label')
  end

  def citation_footer_by_title(title)
    response.parsed_body.css('li.citation').find { |li| li.at('em')&.text&.include?(title) }
            &.at('.citation-footer')
  end

  def link_texts(title)
    citation_footer_by_title(title).css('a').map { |a| a.text.strip }
  end

  def pdf_href(title)
    citation_footer_by_title(title).css('a').find { |a| a.text.strip == 'pdf' }&.[]('href')
  end

  before do
    Website.create!(name: 'lter', url: 'lter.kbs.msu.edu')
    citation('Soil carbon', 'Smith', pdf: true, open_access: true)
    @members_only_pdf = citation('Nitrous oxide', 'Jones', pdf: true, data_url: '10.5061/dryad.123')
    citation('Cover crops', 'Brown')
  end

  it 'gives guests unique labels and a combined abstract+pdf link when the PDF is not open access' do
    get citations_path

    expect(labels).to all(be_present).and(eq(labels.uniq))
    expect(labels).to include('Abstract and PDF: Nitrous oxide, Jones, J. 2020',
                              'Data: Nitrous oxide, Jones, J. 2020',
                              'Abstract: Soil carbon, Smith, J. 2020',
                              'PDF: Soil carbon, Smith, J. 2020')
    expect(link_texts('Nitrous oxide')).to include('abstract + pdf', 'data')
    expect(link_texts('Nitrous oxide')).not_to include('pdf')
    expect(link_texts('Soil carbon')).to include('abstract', 'pdf')
    expect(response.body).not_to include('member-only', 'non-member')
  end

  it 'gives members separate abstract and pdf links for non-open-access PDFs' do
    sign_in FactoryBot.create(:user)
    get citations_path

    expect(labels).to all(be_present).and(eq(labels.uniq))
    expect(labels).to include('PDF: Nitrous oxide, Jones, J. 2020',
                              'Abstract: Nitrous oxide, Jones, J. 2020',
                              'Data: Nitrous oxide, Jones, J. 2020')
    expect(labels).not_to include('Abstract and PDF: Nitrous oxide, Jones, J. 2020')
    expect(link_texts('Nitrous oxide')).to include('abstract', 'pdf', 'data')
    expect(link_texts('Nitrous oxide')).not_to include('abstract + pdf')
    expect(pdf_href('Nitrous oxide')).to include(download_citation_path(@members_only_pdf))
  end

  # Sibling fragment caches: shared citation body must not bake in a guest or member footer.
  it 'keeps guest and member footers distinct when fragment caching is on' do
    previous = ActionController::Base.perform_caching
    previous_store = Rails.cache
    ActionController::Base.perform_caching = true
    Rails.cache = ActiveSupport::Cache::MemoryStore.new

    get citations_path
    expect(link_texts('Nitrous oxide')).to include('abstract + pdf')

    sign_in FactoryBot.create(:user)
    get citations_path
    expect(link_texts('Nitrous oxide')).to include('abstract', 'pdf')
    expect(link_texts('Nitrous oxide')).not_to include('abstract + pdf')
  ensure
    ActionController::Base.perform_caching = previous
    Rails.cache = previous_store
  end
end
