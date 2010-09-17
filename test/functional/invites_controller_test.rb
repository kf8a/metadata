require 'test_helper'

class InvitesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:invites)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create invite" do
    assert_difference('Invite.count') do
      post :create, :invite => { }
    end

    assert_redirected_to invite_path(assigns(:invite))
  end

  test "should show invite" do
    get :show, :id => invites(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => invites(:one).to_param
    assert_response :success
  end

  test "should update invite" do
    put :update, :id => invites(:one).to_param, :invite => { }
    assert_redirected_to invite_path(assigns(:invite))
  end

  test "should destroy invite" do
    assert_difference('Invite.count', -1) do
      delete :destroy, :id => invites(:one).to_param
    end

    assert_redirected_to invites_path
  end
end
