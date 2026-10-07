# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Protocol, '#search_document' do
  before do
    Searchable # ensure SiteSearchSyncJob is loaded
    allow(SiteSearchSyncJob).to receive(:perform_later)
    Rails.application.routes.default_url_options[:host] ||= 'example.com'
    @lter = Website.find_or_create_by!(name: 'lter')
    @sponsor = Sponsor.first || FactoryBot.create(:sponsor)
  end

  def build_protocol(**attrs)
    websites = attrs.delete(:websites)
    datatables = attrs.delete(:datatables)
    people = attrs.delete(:people)
    dataset = attrs.delete(:dataset)

    protocol = FactoryBot.create(
      :protocol,
      {
        title: 'Soil sampling protocol',
        abstract: 'How to sample soil.',
        body: 'Step one. Step two.',
        active: true,
        dataset: dataset
      }.merge(attrs)
    )
    protocol.websites = websites if websites
    protocol.datatables = datatables if datatables
    Array(people).each { |person| protocol.people << person }
    protocol
  end

  describe '#search_indexable?' do
    it 'is true when active with an lter website' do
      expect(build_protocol(websites: [@lter])).to be_search_indexable
    end

    it 'is true when active with blank websites (historic lter)' do
      expect(build_protocol(websites: [], dataset: nil)).to be_search_indexable
    end

    it 'is true when active via an lter dataset website' do
      dataset = FactoryBot.create(:dataset, website: @lter, sponsor: @sponsor)
      expect(build_protocol(websites: [], dataset: dataset)).to be_search_indexable
    end

    it 'is false when only on glbrc' do
      glbrc = Website.find_or_create_by!(name: 'glbrc')
      expect(build_protocol(websites: [glbrc], dataset: nil)).not_to be_search_indexable
    end

    it 'is true when on both lter and glbrc' do
      glbrc = Website.find_or_create_by!(name: 'glbrc')
      expect(build_protocol(websites: [glbrc, @lter], dataset: nil)).to be_search_indexable
    end

    it 'is false when inactive' do
      expect(build_protocol(websites: [@lter], active: false)).not_to be_search_indexable
    end
  end

  describe '#search_document' do
    it 'returns a Typesense document for an active lter protocol' do
      dataset = FactoryBot.create(:dataset, website: @lter, sponsor: @sponsor)
      datatable = FactoryBot.create(
        :datatable,
        title: 'Soil carbon flux',
        dataset: dataset,
        variates: []
      )
      person = FactoryBot.create(:person, given_name: 'Jane', sur_name: 'Smith')
      protocol = build_protocol(websites: [@lter], datatables: [datatable], people: [person])
      protocol.theme_list.add('biogeochemistry')
      protocol.save!

      doc = protocol.search_document

      expect(doc).to eq(
        id: protocol.search_id,
        source: 'rails',
        type: 'protocol',
        title: 'Soil sampling protocol',
        headings: 'Soil carbon flux',
        variates: [],
        body: 'How to sample soil. Step one. Step two.',
        tags: ['biogeochemistry', 'Jane Smith'],
        updated_at: protocol.updated_at.to_i,
        priority: 0,
        url: Rails.application.routes.url_helpers.protocol_url(protocol),
        excerpt: 'How to sample soil. Step one. Step two.'
      )
    end

    it 'joins multiple datatable titles in headings' do
      dataset = FactoryBot.create(:dataset, website: @lter, sponsor: @sponsor)
      tables = [
        FactoryBot.create(:datatable, title: 'Table A', dataset: dataset, variates: []),
        FactoryBot.create(:datatable, title: 'Table B', dataset: dataset, variates: [])
      ]
      protocol = build_protocol(websites: [@lter], datatables: tables)

      expect(protocol.search_document[:headings]).to eq('Table A. Table B')
    end

    it 'returns empty body and excerpt when abstract and body are blank' do
      doc = build_protocol(websites: [@lter], abstract: nil, body: nil).search_document

      expect(doc[:body]).to eq('')
      expect(doc[:excerpt]).to eq('')
    end

    it 'strips HTML from body and excerpt' do
      doc = build_protocol(
        websites: [@lter],
        abstract: '<p>Hello</p>',
        body: '<b>world</b>'
      ).search_document

      expect(doc[:body]).to eq('Hello world')
      expect(doc[:excerpt]).to eq('Hello world')
    end
  end
end
