# frozen_string_literal: true

require File.expand_path('../../test_helper',__FILE__)

class StudiesControllerTest < ActionController::TestCase
  context 'with an admin user' do
    setup do
      sign_in(FactoryBot.create(:admin_user))
    end

    context 'on GET to :index' do
      setup do
        get :index
      end

      should respond_with :success
    end

    context 'on GET to :edit' do
      setup do
        @study = FactoryBot.create(:study, id: 3)
        get :edit, params: { id: 3 }
      end

      should respond_with :success
    end

    context 'on POST to :update' do
      setup do
        @study = FactoryBot.create(:study, id: 3)
        post :update, params: { id: 3, study: { title: "New Title" } }
      end

      should redirect_to("the datatables page") { datatables_url }

      should 'assign to study' do
        assert_equal assigns[:study], @study
      end
    end
  end
end
