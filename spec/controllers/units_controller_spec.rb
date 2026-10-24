# frozen_string_literal: true

require 'rails_helper'

describe UnitsController, type: :controller  do
  before do
    sign_in FactoryBot.create(:admin_user)

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
      expect(response.code).to eq '200'
    end
  end

  context 'PUT :update' do
    before do
      allow(@unit).to receive(:update).and_return(true)
      put :update, params: { id: 1, unit: { name: 'new name' } }
    end
    it { should redirect_to units_url }
    it { assigns(:unit) }
  end

  context 'PUT :update on a saved custom unit' do
    it 'updates only the permitted attributes' do
      allow(Unit).to receive(:find).and_call_original
      unit = Unit.create!(name: 'old', in_eml: false)
      put :update, params: { id: unit.id, unit: { name: 'new', definition: 'defined', in_eml: true } }

      unit.reload
      expect(unit.name).to eq 'new'
      expect(unit.definition).to eq 'defined'
      expect(unit.in_eml).to be false
    end
  end

  context 'with an EML standard unit' do
    before do
      allow(@unit).to receive(:in_eml).and_return(true)
    end

    it 'redirects GET :edit to the unit' do
      get :edit, params: { id: 1 }
      expect(response).to redirect_to unit_url(@unit)
    end

    it 'does not update on PUT :update' do
      expect(@unit).not_to receive(:update)
      put :update, params: { id: 1 }
      expect(response).to redirect_to unit_url(@unit)
    end
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
