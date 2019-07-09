# frozen_string_literal: true

require 'rails_helper'

describe StudiesController, type: :controller do
  render_views

  before(:each) do
    sign_in(FactoryBot.create(:admin_user))
    # @controller.current_user = FactoryBot.create :admin_user
  end

  describe 'GET :index' do
    before(:each) do
      @study = FactoryBot.create :study
      get :index
    end

    it { should render_template 'index' }
    it { assigns :study_roots }
  end
end
