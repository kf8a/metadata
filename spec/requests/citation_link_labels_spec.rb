# frozen_string_literal: true

require 'rails_helper'

# Every citation on the publications page has links reading "abstract" and "pdf", so the links need
# labels that tell a screen reader user which citation each one belongs to.
RSpec.describe 'Citation link labels', type: :request do
  def citation(title, sur_name, pdf: false, open_access: false, data_url: nil)
    citation = ArticleCitation.create!(title:, pub_year: 2020, state: 'published', open_access:, data_url:,
                                       website: Website.find_by!(name: 'lter'),
                                       authors: [Author.new(sur_name:, given_name: 'Jo', seniority: 1)])
    citation.pdf.attach(io: StringIO.new('%PDF-1.4'), filename: 'paper.pdf', content_type: 'application/pdf') if pdf
    citation
  end

  # Signed-in visitors see the .member-only links and everyone else the .non-member ones
  def labels(audience)
    response.parsed_body.css(".#{audience} a, .citation-footer a[href^='https://doi']").pluck('aria-label')
  end

  before do
    Website.create!(name: 'lter', url: 'lter.kbs.msu.edu')
    citation('Soil carbon', 'Smith', pdf: true, open_access: true)
    citation('Nitrous oxide', 'Jones', pdf: true, data_url: '10.5061/dryad.123')
    citation('Cover crops', 'Brown')
    get citations_path
  end

  it 'gives each link a label naming its citation' do
    %w[non-member member-only].each do |audience|
      expect(labels(audience)).to all(be_present).and(eq(labels(audience).uniq))
    end
    expect(labels('member-only')).to include('PDF: Nitrous oxide, Jones, J. 2020',
                                             'Data: Nitrous oxide, Jones, J. 2020')
    expect(labels('non-member')).to include('Abstract and PDF: Nitrous oxide, Jones, J. 2020')
  end
end
