require File.dirname(__FILE__) + '/../test_helper'

class DatatableTest < ActiveSupport::TestCase
  
  
  Factory.define :datatable do |d|
    d.name 'KBS001_001'
    d.object 'select now() as sample_date'
  end
  
  context 'temporal extent' do
    setup do
      @datatable = Factory.create(:datatable)
    end
    
    should 'respond_to temporal_extent' do
      assert @datatable.temporal_extent
    end
    
    should 'return todays date' do
      extent = @datatable.temporal_extent
      assert extent[:end_date].kind_of?(Time)
      assert extent[:begin_date].kind_of?(Time)
      assert extent[:end_date] == extent[:begin_date]
      assert extent[:end_date].to_date == Time.now.to_date
    end
    
  end

end
