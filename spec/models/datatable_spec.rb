# frozen_string_literal: true

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

  describe 'row queries' do
    def rows(sql)
      ActiveRecord::Base.connection.execute(sql).map { |row| row['n'] }
    end

    {
      'a plain query' => 'select g as n from generate_series(1, 20) g order by g desc',
      'a trailing semicolon' => "select g as n from generate_series(1, 20) g order by g desc ;\n",
      'a trailing comment' => 'select g as n from generate_series(1, 20) g order by g desc -- newest first',
      'its own limit' => 'select g as n from generate_series(1, 20) g order by g desc limit 50'
    }.each do |shape, sql|
      context "with #{shape}" do
        before do
          @datatable.update!(object: sql, number_of_released_records: 15, excerpt_limit: 3)
        end

        it 'limits the excerpt to the first released rows' do
          expect(@datatable.data_preview.map { |row| row['n'] }).to eq [15, 14, 13]
        end

        it 'downloads only the released rows' do
          expect(rows(@datatable.approved_data_query)).to eq (1..15).to_a.reverse
        end

        it 'downloads every row for admins' do
          expect(rows(@datatable.full_data_query).size).to eq 20
        end
      end
    end

    it 'treats every row as released when the count is not set' do
      @datatable.update!(object: 'select g as n from generate_series(1, 20) g order by g desc;',
                         number_of_released_records: nil)

      expect(rows(@datatable.approved_data_query).size).to eq 20
    end
  end
end
