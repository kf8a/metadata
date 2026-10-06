# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Citation, '#search_document' do
  before do
    allow(SiteSearchSyncJob).to receive(:perform_later)
    Rails.application.routes.default_url_options[:host] ||= 'example.com'
    Website.find_or_create_by!(name: 'lter')
  end

  def published_citation(factory: :article_citation, **attrs)
    author = FactoryBot.build(:author, sur_name: 'Smith', given_name: 'Jane', seniority: 1)
    FactoryBot.create(
      factory,
      {
        title: 'A study of soil carbon',
        abstract: 'An abstract of the article.',
        pub_year: 2020,
        state: 'published',
        authors: [author]
      }.merge(attrs)
    )
  end

  describe '#search_indexable?' do
    it 'is true when published on an lter website' do
      expect(published_citation(website: Website.find_by!(name: 'lter'))).to be_search_indexable
    end

    it 'is true when published with a nil website (historic lter)' do
      expect(published_citation(website: nil)).to be_search_indexable
    end

    it 'is false when published on a glbrc website' do
      glbrc = Website.find_or_create_by!(name: 'glbrc')
      expect(published_citation(website: glbrc)).not_to be_search_indexable
    end

    it 'is false when not published' do
      %w[draft submitted forthcoming].each do |state|
        citation = published_citation(state: state)
        expect(citation).not_to be_search_indexable
      end
    end
  end

  describe '#search_document' do
    it 'returns a Typesense document for a published article' do
      study = FactoryBot.create(:study)
      treatment = FactoryBot.create(
        :treatment,
        study: study,
        name: 'T1',
        description: 'conventional',
        use_in_citations: true
      )
      citation = published_citation(publication: 'Ecology')
      citation.treatments << treatment

      doc = citation.search_document

      expect(doc).to eq(
        id: citation.search_id,
        source: 'rails',
        type: 'article',
        title: citation.formatted,
        headings: 'Ecology',
        variates: [],
        body: 'An abstract of the article.',
        tags: ['T1 conventional'],
        updated_at: citation.updated_at.to_i,
        priority: 0,
        url: Rails.application.routes.url_helpers.citation_url(citation),
        excerpt: 'An abstract of the article.'
      )
    end

    it 'uses treatment name alone when name equals description' do
      study = FactoryBot.create(:study)
      treatment = FactoryBot.create(
        :treatment,
        study: study,
        name: 'Control',
        description: 'Control',
        use_in_citations: true
      )
      citation = published_citation
      citation.treatments << treatment

      expect(citation.search_document[:tags]).to eq(['Control'])
    end

    it 'uses an empty headings string when publication is blank' do
      expect(published_citation(publication: nil).search_document[:headings]).to eq('')
    end

    it 'maps STI classes to type' do
      expect(published_citation(factory: :book_citation).search_document[:type]).to eq('book')
      expect(published_citation(factory: :chapter_citation).search_document[:type]).to eq('chapter')
      expect(published_citation(factory: :thesis_citation).search_document[:type]).to eq('thesis')
      expect(published_citation(factory: :citation).search_document[:type]).to eq('article')
    end

    it 'returns empty body and excerpt when abstract is blank' do
      doc = published_citation(abstract: nil).search_document

      expect(doc[:body]).to eq('')
      expect(doc[:excerpt]).to eq('')
    end

    it 'strips HTML from body and excerpt' do
      doc = published_citation(abstract: '<p>Hello <b>world</b></p>').search_document

      expect(doc[:body]).to eq('Hello world')
      expect(doc[:excerpt]).to eq('Hello world')
    end
  end
end
