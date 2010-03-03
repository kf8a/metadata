require File.dirname(__FILE__) + '/../test_helper'

class StudyTest < ActiveSupport::TestCase
  
  should_have_many :datatables
  should_have_and_belong_to_many :datasets

  context 'querying for datatables' do
    setup do
      @study = Factory.create(:study, :weight => 200)
      2.times {Factory.create(:study) }
      @study2 = Factory.create(:study, :weight=>100)
      @datatable  = Factory.create(:datatable, :study => @study)
      @datatable2 = Factory.create(:datatable, :study => @study2)
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
    
    should 'return the studies in the proper order' do
      studies = Study.find_all_with_datatables([@datatable, @datatable2], {:order => :weight})
      assert studies.size == 2
      assert studies[0] == @study2
      assert studies[1] == @study
    end
  end

end
