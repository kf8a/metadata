require 'spec_helper'

describe StudiesController do
  render_views

  before(:each) do
    @controller.current_user = FactoryGirl.create :admin_user
  end

  describe 'GET :index' do
    before(:each) do
      @study = FactoryGirl.create :study
      get :index
    end

    it { should render_template 'index' }
    it { should assign_to :study_roots }
  end

  describe 'POST :move_to' do
    before(:each) do
      @study = FactoryGirl.create :study
      @another_study = FactoryGirl.create :study
      post :move_to, {:id=> @study.id, :parent_id => @another_study.id}
    end

    it "should make the first study a child of the other" do
      @study.reload
      assert @study.parent == @another_study
    end
  end

  describe 'POST :move_before' do
    before(:each) do
      @study = FactoryGirl.create :study
      @another_study = FactoryGirl.create :study
      post :move_before, {:id=> @study.id, :parent_id => @another_study.id}
    end

    it "should make the first study a sibling of the other" do
      @study.reload
      assert @study.siblings.include?(@another_study)
    end
  end
end
