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

  it 'is false when website is glbrc' do
    glbrc = Website.find_or_create_by!(name: 'glbrc')
    expect(build_dataset(website: glbrc)).not_to be_search_indexable
  end

  it 'is false when not on_web' do
    lter = Website.find_or_create_by!(name: 'lter')
    expect(build_dataset(website: lter, on_web: false)).not_to be_search_indexable
  end
end
