require File.dirname(__FILE__) + '/../test_helper'

class DatasetTest < ActiveSupport::TestCase
    
  should_have_many :datatables
  should_have_many :affiliations
    
  should_have_and_belong_to_many :themes
  should_have_and_belong_to_many :studies
  
  context 'dataset' do
    setup do
      @dataset = Factory.create(:dataset)
    end

    should 'respond to update_temporal_extent' do
      assert @dataset.respond_to?('update_temporal_extent')
    end

    should 'respond to temporal extent' do
      assert @dataset.respond_to?('temporal_extent')
    end
  end
  
  context 'no temporal extent' do
    setup do
      @dataset = Factory.create(:dataset, :initiated => '2000-1-1', 
        :datatables => [Factory.create(:datatable, :object => 'select 1')])
    end
    
    should 'not update temporal extent if extent is missing' do
      @dataset.update_temporal_extent
      assert @dataset.initiated == Date.parse('2000-1-1')
      assert @dataset.completed == nil
    end
  end
   
  context 'Current Temporal Extent' do
    setup do
      @dataset = Factory.create(:dataset, 
        :datatables  => [Factory.create(:datatable, :object => 'select 1'), 
                         Factory.create(:datatable, 
                         :object => "select now() as sample_date"),
                         Factory.create(:datatable, :object => 'select 1')])
    end
  
    should 'be today' do
      dates = @dataset.temporal_extent
      assert  dates[:begin_date] == Date.today
      assert dates[:end_date] == Date.today
    end
    
    should 'update temporal extent to today' do
      @dataset.update_temporal_extent
      assert @dataset.initiated == Date.today
      assert @dataset.completed == Date.today
    end

  end
  
  context 'past temporal extent' do
    setup do
      @dataset = Factory.create(:dataset, 
        :datatables  => [Factory.create(:datatable), 
                         Factory.create(:datatable, 
                         :object => "select now() - interval '1 year' as sample_date")])
    end
    
    should 'be today to a year ago' do
      dates = @dataset.temporal_extent
      assert  dates[:begin_date] == Date.today - 1.year
      assert dates[:end_date] == Date.today
    end
    
    
  end
  
  context 'eml generatation' do
    setup do 
      @dataset = Factory.create(:dataset, :initiated => Date.today, :completed => Date.today)
      @dataset_no_date = Factory.create(:dataset, :datatables  => [Factory.create(:datatable),  Factory.create(:datatable)])    
    end
    
    should 'be successful' do
      assert !@dataset.to_eml.nil?
      assert !@dataset_no_date.to_eml.nil?
    end
  end

end
