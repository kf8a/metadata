# frozen_string_literal: true

require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

describe UnitsController, type: :controller  do
  before do
    user = User.new
    allow(user).to receive(:admin?).and_return(true)
    # allow(request.env['warden']).to receive(:authenticate!).and_return(user)
    # allow(controller).to receive(:current_user).and_return(user)

    sign_in user

    @unit = Unit.new
    allow(@unit).to receive(:id).and_return(1)
    allow(@unit).to receive(:save).and_return(true)
    allow(Unit).to receive(:find).with('1').and_return(@unit)
  end

  context 'GET :index' do
    before do
      get :index
    end
    it 'is successful' do
      expect(response.code).to eq '200'
    end
  end

  context 'GET :edit' do
    before do
      get :edit, params: { id: @unit }
    end
    it 'is successful' do
      expect(response.code).to eq '302'
    end
  end

  context 'PUT :update' do
    before do
      allow(@unit).to receive(:update_attributes).and_return(true)
      put :update, params: { id: 1 }
    end
    it { should redirect_to units_url }
    it { assigns(:unit) }
  end

  context 'GET :show' do
    before do
      get :show, params: { id: @unit }
    end
    it 'is successful' do
      expect(response.code).to eq '200'
    end
    it { assigns(:unit) }
  end
end
