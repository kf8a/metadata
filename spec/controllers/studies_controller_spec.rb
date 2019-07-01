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

  describe 'POST :move_to' do
    before(:each) do
      @study = FactoryBot.create :study
      @another_study = FactoryBot.create :study
      post :move_to, params: { id: @study.id, parent_id: @another_study.id }
    end

    it 'should make the first study a child of the other' do
      @study.reload
      assert @study.parent == @another_study
    end
  end

  describe 'POST :move_before' do
    before(:each) do
      @study = FactoryBot.create :study
      @another_study = FactoryBot.create :study
      post :move_before, params: { id: @study.id, parent_id: @another_study.id }
    end

    it 'should make the first study a sibling of the other' do
      @study.reload
      assert @study.siblings.include?(@another_study)
    end
  end
end
