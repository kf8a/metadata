require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe UnitsController do

  before do
    user = double(:user).stub(:admin?).and_return(:true)
    @controller.current_user = user

    @unit = Unit.new
    @unit.stub(:id).and_return(1)
    @unit.stub(:save).and_return(true)
    Unit.stub(:find).with('1').and_return(@unit)
  end

  context 'GET :index' do
    before do
      get :index
    end
    it {should respond_with :success }
    it {assigns(:units) }
  end

  context 'GET :edit' do
    before do
      get :edit, :id => @unit
    end
    it {should respond_with :success }
    it {assigns(:unit) }
  end

  context 'PUT :update' do
    before do
      @unit.stub(:update_attributes).and_return(true)
      put :update, :id=>1
    end
    it {should redirect_to units_url }
    it {assigns(:unit) }
  end

  context 'GET :show' do
    before do
      get :show, :id=>@unit
    end
    it {should respond_with :success }
    it {assigns(:unit) }
  end
end
