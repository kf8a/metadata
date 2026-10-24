# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dataset, '#search_indexable?' do
  before do
    allow(SiteSearchSyncJob).to receive(:perform_later)
    @sponsor = Sponsor.first || FactoryBot.create(:sponsor)
  end

  def build_dataset(**attrs)
    FactoryBot.create(
      :dataset,
      {
        abstract: 'some abstract',
        on_web: true,
        sponsor: @sponsor
      }.merge(attrs)
    )
  end

  it 'is true when on_web for an lter website' do
    lter = Website.find_or_create_by!(name: 'lter')
    expect(build_dataset(website: lter)).to be_search_indexable
  end

  it 'is true when on_web with a nil website (historic lter)' do
    expect(build_dataset(website: nil)).to be_search_indexable
  end

  it 'is true when on_web for a glbrc website' do
    glbrc = Website.find_or_create_by!(name: 'glbrc')
    expect(build_dataset(website: glbrc)).to be_search_indexable
  end

  it 'is false when not on_web' do
    lter = Website.find_or_create_by!(name: 'lter')
    expect(build_dataset(website: lter, on_web: false)).not_to be_search_indexable
  end

  it 'queues a search sync when saved' do
    dataset = build_dataset
    expect(SiteSearchSyncJob).to have_received(:perform_later).with('Dataset', dataset.id)
  end

  describe '#search_document' do
    it 'returns a Typesense document for the dataset' do
      Rails.application.routes.default_url_options[:host] ||= 'example.com'
      dataset = build_dataset(title: 'Soil carbon', abstract: '<p>Carbon in <b>soils</b>.</p>',
                              keyword_list: 'carbon, soil')

      expect(dataset.search_document).to eq(
        id: "rails-dataset-#{dataset.id}",
        source: 'rails',
        type: 'dataset',
        title: 'Soil carbon',
        headings: '',
        variates: [],
        body: 'Carbon in soils.',
        tags: %w[carbon soil],
        updated_at: dataset.updated_at.to_i,
        priority: 0,
        url: Rails.application.routes.url_helpers.dataset_url(dataset),
        excerpt: 'Carbon in soils.'
      )
    end
  end
end
