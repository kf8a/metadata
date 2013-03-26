require 'spec_helper'
require 'score_card.rb'

describe ScoreCard do
  let (:score_card) {ScoreCard.new}

  before do
    @datatable = stub()
    @datatable.stub('id').and_return(1)
    @datatable.stub('status').and_return('active')
    @datatable.stub('variate_names').and_return(['sample_date'])
    @datatable.stub('update_frequency_days').and_return(365)
    @datatable.stub('approved_data_query').and_return("select '2013-1-1'::date as sample_date")
    score_card.stub('current_year').and_return(2013)
  end

  it 'returns scores for years' do
    @datatable.stub('object').and_return("select 2013 as year")
    @datatable.stub('approved_data_query').and_return("select 2013 as year")
    @datatable.stub('variate_names').and_return(['year'])

    score_card.score(@datatable).should == [{:year => 2013, :count=> 1, :approved => 1.0}]
  end

  it 'returns scores for sample_dates' do
    @datatable.stub('object').and_return("select '2013-1-1'::date as sample_date")

    score_card.score(@datatable).should == [{:year => 2013, :count=> 1, :approved => 1.0}]
  end

  it 'returns zero scores when there is no data and the dataset is not complete' do
    @datatable.stub('object').and_return("select '2012-1-1'::date as sample_date")
    @datatable.stub('approved_data_query').and_return("select '2012-1-1'::date as sample_date")

    score_card.score(@datatable).should == [{:year => 2013, :count => 0}, {:year => 2012, :count => 1.0, :approved => 1.0}]
  end

  it 'returns addtional zero scores based on the update frequency' do
    @datatable.stub('object').and_return("select '2010-1-1'::date as sample_date")
    @datatable.stub('approved_data_query').and_return("select '2010-1-1'::date as sample_date")
    @datatable.stub(:update_frequency_days).and_return(365*3)

    score_card.score(@datatable).should == [{:year => 2013, :count => 0}, {:year => 2010, :count => 1.0, :approved => 1.0}]
  end

  it 'returns no zero scores when the dataset is complete' do
    @datatable.stub('object').and_return("select '2012-1-1'::date as sample_date")
    @datatable.stub('approved_data_query').and_return("select '2012-1-1'::date as sample_date")
    @datatable.stub('status').and_return('completed')

    score_card.score(@datatable).should == [{:year => 2012, :count => 1.0, :approved => 1.0}]
  end


end
