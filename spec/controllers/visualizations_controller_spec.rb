require 'spec_helper'

describe VisualizationsController do
  describe 'A visualization exists.' do
    before(:each) do
      @visualization = FactoryGirl.create(:visualization)
    end

    describe 'GET :show' do
      before(:each) do
        get :show, :id => @visualization.id, :format => :json
      end

      it { should respond_with :success }
    end
  end
end
