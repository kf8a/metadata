require File.dirname(__FILE__) + '/../test_helper'

class DatatableTest < ActiveSupport::TestCase
    
  context 'datatable with sample_date' do
    setup do
      @datatable = Factory.create(:datatable)
    end
    
    should 'respond_to has_data_in_interval?' do
      assert @datatable.respond_to?('within_interval?')
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
     
    should 'work with time values as well' do
      assert @datatable.within_interval?(Date.today, Time.now + 1.day)
    end
  end
  
  context 'datatable without sample_date' do
    setup do
      @datatable = Factory.create(:datatable)
      @datatable.object = 'select 1 as treatment'
    end
    
    should 'return false if interval does not include today' do
      assert !@datatable.within_interval?(Date.today + 1.day, Date.today + 4.day)
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
