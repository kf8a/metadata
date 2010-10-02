require 'test_helper'

class StudiesControllerTest < ActionController::TestCase

  context 'with an admin user' do
    setup do 
      @controller.current_user = Factory.create :admin_user
    end
    
    context "on GET to :index" do
      setup do
        get :index
      end
      
      should respond_with :success
      should assign_to :study_roots
    end
    
    context 'on GET to :edit' do
      setup do
        @study = Factory.create(:study, :id => 3)
        get :edit, :id => 3
      end

      should respond_with :success
      should assign_to(:study).with(@study)
    end

    context 'on POST to :update' do
      setup do
        @study = Factory.create(:study, :id => 3)
        post :update, :id => 3
      end

      should redirect_to("the datatables page") {datatables_url}
      should assign_to(:study).with(@study)
    end
  end
end
