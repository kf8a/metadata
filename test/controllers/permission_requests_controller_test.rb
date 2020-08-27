# frozen_string_literal: true

require File.expand_path('../../test_helper',__FILE__)

class PermissionRequestsControllerTest < ActionController::TestCase
  context "a protected and owned datatable" do
    setup do
      @datatable = FactoryBot.create(:protected_datatable)
      @owner = FactoryBot.create(:email_confirmed_user)
      FactoryBot.create(:ownership, user: @owner, datatable: @datatable)
    end

    context "and not signed in at all" do
      context "POST :create" do
        setup do
          post :create, params: { datatable: @datatable }
        end

        should "not create a permission request" do
          assert_nil PermissionRequest.find_by(datatable_id: @datatable.id, user_id: @owner.id)
        end
      end
    end

    context "and signed in as a valid user" do
      setup do
        @user = FactoryBot.create(:email_confirmed_user)
        sign_in(@user)
      end

      context "POST :create" do
        setup do
          post :create, params: { datatable: @datatable }
        end

        should "create a permission request" do
          assert PermissionRequest.find_by(datatable_id: @datatable.id, user_id: @user.id)
        end
      end
    end
  end
end
