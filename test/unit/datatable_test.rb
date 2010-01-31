require File.dirname(__FILE__) + '/../test_helper'

class DatatableTest < ActiveSupport::TestCase
  
  context 'datatable' do
    setup do
      @datatable = Factory.create(:datatable)
    end
    
    should 'respond to temporal_extent' do
      assert @datatable.respond_to?('temporal_extent')
    end
    
    should 'respond_to has_data_in_interval?' do
      assert @datatable.respond_to?('within_interval?')
    end
    
    should 'respond to update_temporal_extent' do
      assert @datatable.respond_to?('update_temporal_extent')
    end
  end
  
    
  context 'datatable with sample_date' do
    setup do
      @datatable = Factory.create(:datatable)
      @old_data = Factory.create(:datatable, :object => %q{select now() - interval '3 year' as sample_date})
    end
    
    
    should 'return true if interval includes today' do
     assert @datatable.within_interval?(Date.today, Date.today + 1.day)
    end
    
    should 'return false if the interval is later than the data times' do
      assert !@datatable.within_interval?(Date.today + 1.day, Date.today + 4.day)
    end
    
    should 'return false if the interval is earlier than the data times' do
      assert !@datatable.within_interval?(Date.today - 4.day, Date.today - 2.day)
    end
         
    
    should 'have the correct temporal extent' do
      dates = @datatable.temporal_extent
      assert dates[:begin_date] == Date.today
      assert dates[:end_date] == Date.today
      
      dates = @old_data.temporal_extent
      assert dates[:begin_date] == Date.today - 3.years
      assert dates[:end_date] == Date.today - 3.years
    end
    
    should 'cache the temporal extent' do
      assert @datatable.begin_date.nil?
      assert @datatable.end_date.nil?
      @datatable.update_temporal_extent
      assert @datatable.begin_date == Date.today
      assert @datatable.end_date == Date.today
      
      assert @old_data.begin_date.nil?
      assert @old_data.end_date.nil?
      @old_data.update_temporal_extent
      assert @old_data.begin_date == Date.today - 3.years
      assert @old_data.end_date == Date.today - 3.years
    end
    
  end

  context 'datatable with range of dates' do
    setup do
      @datatable = Factory.create(:datatable, :object => %q{select current_date + (random() * n)::integer as sample_date from generate_series(0,11) n})
    end
    
    should 'have the begin_date before the end_date' do
      dates = @datatable.temporal_extent
      assert dates[:begin_date] < dates[:end_date]
    end
  end
  
  context 'datatable without sample_date' do
    setup do
      @datatable = Factory.create(:datatable)
      @datatable.object = 'select 1 as treatment'
    end
    
    should 'return false for within_interval?' do
      assert !@datatable.within_interval?(Date.today + 1.day, Date.today + 4.day)
    end
    
    should 'return nils for temporal_extent' do
      dates = @datatable.temporal_extent
      assert dates[:begin_date].nil?
      assert dates[:end_date].nil?
    end
    
  end
  
  context 'datatable with different date representations' do
    setup do 
      obs_date = Factory.create(:datatable, :object => %q{select current_date as obs_date})
      datetime = Factory.create(:datatable, :object => %q{select current_date as datetime})
      date = Factory.create(:datatable, :object => %q{select current_date as date})
      @date_representations = [obs_date, datetime, date]
    end
    
    should 'return true if interval includes today' do
      @date_representations.each do |date_representation|
        assert date_representation.within_interval?(Date.today, Date.today + 1.day)
      end
    end
    
    should 'return false if the interval is later than the data times' do
      @date_representations.each do |date_representation|
        assert !date_representation.within_interval?(Date.today + 1.day, Date.today + 4.day)
      end
    end
    
    should 'return false if the interval is earlier than the data times' do
      @date_representations.each do |date_representation|
        assert !date_representation.within_interval?(Date.today - 4.day, Date.today - 2.day)
      end
    end
         
    
    should 'have the correct temporal extent' do
      @date_representations.each do |date_representation|     
        dates = date_representation.temporal_extent
        assert dates[:begin_date] == Date.today
        assert dates[:end_date] == Date.today
      end
    end
    
    should 'cache the temporal extent' do
      @date_representations.each do |date_representation|
        assert date_representation.begin_date.nil?
        assert date_representation.end_date.nil?
        date_representation.update_temporal_extent
        assert date_representation.begin_date == Date.today
        assert date_representation.end_date == Date.today
      end
    end
  end
  
  context 'eml generation' do
    setup do 
      @datatable = Factory.create(:datatable)
    end
    
    should 'return respond to to_eml' do
      assert @datatable.respond_to?('to_eml')
    end
    
    should 'return an eml datatable fragment' do
      eml = @datatable.to_eml
      assert eml.to_s =~ /datatable/
    end
  end
end
