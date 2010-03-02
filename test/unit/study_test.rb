require File.dirname(__FILE__) + '/../test_helper'

class StudyTest < ActiveSupport::TestCase
  
  should_have_many :datatables
  should_have_and_belong_to_many :datasets

  context 'querying for datatables' do
    setup do
      @study = Factory.create(:study)
      assert @study.save
      2.times {Factory.create(:study).save }
      @datatable  = Factory.create(:datatable, :study => @study)
      @datatable.save
    end
    
    should 'return true if queried for included datatables' do
      assert @study.include_datatables?([@datatable])
    end
    
    should 'return false if queried for a non affiliated datatable' do
      assert  !@study.include_datatables?([Factory.create(:datatable)])
    end


    should 'find only the studies that include the datatable' do
      assert Study.find_all_with_datatables([@datatable]) == [@study]
    end
  end

end
