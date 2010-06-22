require 'test_helper'

class StudiesControllerTest < ActionController::TestCase

  context 'on GET to :edit' do
    setup do
      @study = Factory.create(:study, :id => 3)
      get :edit, :id => 3
    end
    
    should respond_with :success
    should assign_to :study
  end
  
  context 'on POST to :update' do
    setup do
      @study = Factory.create(:study, :id => 3)
      post :update, :id => 3
    end

    should respond_with :redirect   #to datatables
    should assign_to :study
  end
end
