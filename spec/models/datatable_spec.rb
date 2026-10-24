require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

describe Datatable do
  before(:each) do
    @datatable = FactoryBot.create(:datatable)
  end

  describe '#csv_headers' do
    before do
      @datatable.dataset.update!(website: Website.create!(name: 'lter', url: 'lter.kbs.msu.edu'))
    end

    it 'links the current dataset DOI' do
      @datatable.dataset.dataset_dois.create!(doi: '10.6073/old', version: 1)
      @datatable.dataset.dataset_dois.create!(doi: '10.6073/current', version: 2)

      expect(@datatable.csv_headers).to include("# https://doi.org/10.6073/current\n")
      expect(@datatable.csv_headers).not_to include('10.6073/old')
    end

    it 'leaves out the DOI line when the dataset has no DOI' do
      expect(@datatable.csv_headers).not_to include('doi.org')
    end
  end
end
