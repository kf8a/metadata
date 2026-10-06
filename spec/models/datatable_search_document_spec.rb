# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Datatable, '#search_document' do
  before do
    allow(SiteSearchSyncJob).to receive(:perform_later)
    @website = Website.find_or_create_by!(name: 'lter')
    @sponsor = Sponsor.first || FactoryBot.create(:sponsor)
  end

  def web_datatable(**attrs)
    dataset = attrs.delete(:dataset) ||
              FactoryBot.create(:dataset, website: @website, sponsor: @sponsor)
    FactoryBot.create(
      :datatable,
      {
        title: 'Soil carbon flux',
        description: 'Measurements of soil respiration.',
        on_web: true,
        theme: FactoryBot.create(:theme, name: 'Biogeochemistry'),
        study: FactoryBot.create(:study, name: 'Main Cropping System Experiment'),
        dataset: dataset
      }.merge(attrs)
    )
  end

  describe '#search_indexable?' do
    it 'is true when on_web for an lter dataset' do
      expect(web_datatable).to be_search_indexable
    end

    it 'is true when on_web and dataset website is nil (historic lter)' do
      dataset = FactoryBot.create(:dataset, website: nil, sponsor: @sponsor)
      expect(web_datatable(dataset: dataset)).to be_search_indexable
    end

    it 'is false when dataset website is glbrc' do
      glbrc = Website.find_or_create_by!(name: 'glbrc')
      dataset = FactoryBot.create(:dataset, website: glbrc, sponsor: @sponsor)
      expect(web_datatable(dataset: dataset)).not_to be_search_indexable
    end

    it 'is false when not on_web' do
      expect(web_datatable(on_web: false)).not_to be_search_indexable
    end
  end

  describe '#search_document' do
    it 'returns a Typesense document for a public datatable' do
      datatable = web_datatable
      datatable.keyword_list.add('carbon')
      datatable.save!

      doc = datatable.search_document

      expect(doc).to eq(
        id: datatable.search_id,
        source: 'rails',
        type: 'datatable',
        title: 'Soil carbon flux',
        headings: 'Biogeochemistry',
        variates: datatable.variate_names,
        body: 'Measurements of soil respiration.',
        tags: ['carbon', 'Main Cropping System Experiment'],
        updated_at: datatable.updated_at.to_i,
        priority: 0,
        url: datatable.datatable_id,
        excerpt: 'Measurements of soil respiration.'
      )
    end

    it 'includes lead investigator names in tags' do
      datatable = web_datatable
      lead_role = Role.find_by(name: 'lead investigator') ||
                  FactoryBot.create(:role, name: 'lead investigator')
      person = FactoryBot.create(:person, given_name: 'Jane', sur_name: 'Smith')
      FactoryBot.create(:data_contribution, datatable: datatable, person: person, role: lead_role)

      expect(datatable.search_document[:tags]).to include('Jane Smith')
    end

    it 'returns empty body and excerpt when description is blank' do
      doc = web_datatable(description: nil).search_document

      expect(doc[:body]).to eq('')
      expect(doc[:excerpt]).to eq('')
    end

    it 'strips HTML from body and excerpt' do
      doc = web_datatable(description: '<p>Hello <b>world</b></p>').search_document

      expect(doc[:body]).to eq('Hello world')
      expect(doc[:excerpt]).to eq('Hello world')
    end
  end
end
