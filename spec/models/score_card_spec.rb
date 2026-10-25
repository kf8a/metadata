# frozen_string_literal: true

require 'rails_helper'
# require 'app/models/score_card.rb'

describe ScoreCard do
  let(:score_card) { ScoreCard.new }

  before do
    @datatable = Datatable.new
    allow(@datatable).to receive('id').and_return(1)
    allow(@datatable).to receive('status').and_return('active')
    allow(@datatable).to receive('variate_names').and_return(['sample_date'])
    allow(@datatable).to receive('update_frequency_days').and_return(365)
    allow(@datatable).to receive('approved_data_query')
      .and_return("select '2013-1-1'::date as sample_date")
    allow(score_card).to receive('current_year').and_return(2013)
  end

  it 'returns no scores when the datatable query is invalid' do
    allow(@datatable).to receive('object').and_return('select missing_column from no_such_table')

    expect(score_card.data(@datatable, 'sample_date')).to eq []
  end

  it 'does not hide errors that are not database errors' do
    allow(@datatable).to receive('object').and_return("select '2013-1-1'::date as sample_date")
    allow(score_card.db_connection).to receive(:execute).and_raise(NoMethodError)

    expect { score_card.data(@datatable, 'sample_date') }.to raise_error(NoMethodError)
  end

  it 'returns scores for years' do
    allow(@datatable).to receive('object').and_return('select 2013 as year')
    allow(@datatable).to receive('approved_data_query').and_return('select 2013 as year')
    allow(@datatable).to receive('variate_names').and_return(['year'])

    expect(score_card.score(@datatable)).to eq [{ year: 2013, count: 1, approved: 1.0 }]
  end

  it 'returns scores when the stored query ends in a semicolon' do
    allow(@datatable).to receive('object').and_return("select '2013-1-1'::date as sample_date;\n")

    expect(score_card.score(@datatable)).to eq [{ year: 2013, count: 1, approved: 1.0 }]
  end

  it 'returns scores for sample_dates' do
    allow(@datatable).to receive('object').and_return("select '2013-1-1'::date as sample_date")

    expect(score_card.score(@datatable)).to eq [{ year: 2013, count: 1, approved: 1.0 }]
  end

  it 'returns zero scores when there is no data and the dataset is not complete' do
    allow(@datatable).to receive('object').and_return("select '2012-1-1'::date as sample_date")
    allow(@datatable).to receive('approved_data_query')
      .and_return("select '2012-1-1'::date as sample_date")

    expect(score_card.score(@datatable)).to eq [{ year: 2013, count: 0 },
                                                { year: 2012, count: 1.0, approved: 1.0 }]
  end

  it 'returns addtional zero scores based on the update frequency' do
    allow(@datatable).to receive('object')
      .and_return("select '2010-1-1'::date as sample_date")
    allow(@datatable).to receive('approved_data_query')
      .and_return("select '2010-1-1'::date as sample_date")
    allow(@datatable).to receive(:update_frequency_days).and_return(365 * 3)

    expect(score_card.score(@datatable)).to eq [{ year: 2013, count: 0 },
                                                { year: 2010, count: 1.0, approved: 1.0 }]
  end

  it 'returns no zero scores when the dataset is complete' do
    allow(@datatable).to receive('object').and_return("select '2012-1-1'::date as sample_date")
    allow(@datatable).to receive('approved_data_query')
      .and_return("select '2012-1-1'::date as sample_date")
    allow(@datatable).to receive('status').and_return('completed')

    expect(score_card.score(@datatable)).to eq [{ year: 2012, count: 1.0, approved: 1.0 }]
  end
end
