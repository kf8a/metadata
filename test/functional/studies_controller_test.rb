require 'test_helper'

class StudiesControllerTest < ActionController::TestCase

  context 'on GET to :edit' do
    setup do
      @study = Factory.create(:study, :id => 3)
      get :edit, :id => 3
    end
    
    should_respond_with :success
    should_assign_to :study
  end
  
  context 'on POST to :update' do
    setup do
      @study = Factory.create(:study, :id => 3)
      post :update, :id => 3
    end

    should_respond_with :redirect   #to datatables
    should_assign_to :study
  end
end
