require 'rails_helper'

describe VisualizationsController, type: :controller do
  describe 'A visualization exists.' do
    before(:each) do
      @visualization = FactoryBot.create(:visualization)
    end

    describe 'GET :show' do
      before(:each) do
        get :show, params: { id: @visualization.id, format: :json }
      end

      it { should respond_with :success }
    end
  end
end
