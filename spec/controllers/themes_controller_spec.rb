require 'spec_helper'

describe ThemesController do
  render_views

  before(:each) do
    @controller.current_user = FactoryGirl.create :admin_user
  end

  describe 'GET :index' do
    before(:each) do
      @theme = FactoryGirl.create :theme
      get :index
    end

    it { should render_template 'index' }
    it { should assign_to :theme_roots }
  end

  describe 'POST :move_to' do
    before(:each) do
      @theme = FactoryGirl.create :theme
      @another_theme = FactoryGirl.create :theme
      post :move_to, {:id=> @theme.id, :parent_id => @another_theme.id}
    end

    it "should make the first theme a child of the other" do
      @theme.reload
      assert @theme.parent == @another_theme
    end
  end

  describe 'POST :move_before' do
    before(:each) do
      @theme = FactoryGirl.create :theme
      @another_theme = FactoryGirl.create :theme
      post :move_before, {:id=> @theme.id, :parent_id => @another_theme.id}
    end

    it "should make the first theme a sibling of the other" do
      @theme.reload
      assert @theme.siblings.include?(@another_theme)
    end
  end
end
