require 'spec_helper'
require 'score_card.rb'

describe ScoreCard do
  let (:score_card) {ScoreCard.new}

  before do
    @datatable = stub()
    @datatable.stub('id').and_return(1)
    @datatable.stub('completed').and_return(false)
  end

  it 'returns scores for years' do
    @datatable.stub('object').and_return("select 2013 as year")
    @datatable.stub('variate_names').and_return(['year'])
    score_card.score(@datatable).should == [{:year => 2013, :score => 1}]
  end

  it 'returns scores for sample_dates' do
    @datatable.stub('object').and_return("select '2013-1-1'::date as sample_date")
    @datatable.stub('variate_names').and_return(['sample_date'])
    score_card.score(@datatable).should == [{:year => 2013, :score => 1}]
  end

  describe 'incomplete datasets' do
    before do
      @datatable.stub('object').and_return("select '2012-1-1'::date as sample_date")
      @datatable.stub('variate_names').and_return(['sample_date'])
    end

    it 'returns zero scores when there is no data and the dataset is not complete' do
      pending 'not ready yet'
      # score_card.score(@datatable).should == {2013=>0, 2012 => 1.0}
    end

    it 'does not return zero scores if the dataset is complete' do
      pending 'not ready yet'
      # @datatable.stub('completed').and_return(true)
      # score_card.score(@datatable).should == {2012 => 1}
    end
  end

end
