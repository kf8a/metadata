require File.dirname(__FILE__) + '/../test_helper'

class StudyTest < ActiveSupport::TestCase

  context 'querying for datatables' do
    setup do
      @study = Factory.create(:study)
      @datatable  = Factory.create(:datatable)
      @study.datasets << Factory.create(:dataset, :datatables => [@datatable])
    end
    
    should 'return true if queried for any datatables' do
      assert @study.include_datatables?
    end

    should 'return true if queried for included datatables' do
      assert @study.include_datatables?([@datatable])
    end
    
    should 'return false if queried for a non affiliated datatable' do
      assert  !@study.include_datatables?([Factory.create(:datatable)])
    end

  end

end
