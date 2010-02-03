require File.dirname(__FILE__) + '/../test_helper'
require 'datasets_controller'

# Re-raise errors caught by the controller.
class DatasetsController; def rescue_action(e) raise e end; end

class DatasetsControllerTest < ActionController::TestCase
  

  def setup
    @controller = DatasetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @dataset = Factory.create(:dataset)
    Factory.create(:dataset)
  end
 
  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_dataset
    old_count = Dataset.count
    post :create, :dataset => {:abstract => 'some text' }
    assert_equal old_count+1, Dataset.count
    
    assert_redirected_to dataset_path(assigns(:dataset))
  end

  def test_should_show_dataset
    get :show, :id => @dataset
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => @dataset
    assert_response :success
  end
  
  def test_should_update_dataset
    put :update, :id => @dataset, :dataset => { }
    assert_redirected_to dataset_path(assigns(:dataset))
  end
  
  def test_should_destroy_dataset
    old_count = Dataset.count
    delete :destroy, :id => @dataset
    assert_equal old_count-1, Dataset.count
    
    assert_redirected_to datasets_path
  end
  
  context 'GET index' do
    setup do
      get :index
    end
    
    should_assign_to :datasets
    should_assign_to :people
    should_assign_to :themes
    
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
    
  end
  
  context 'GET with empty search parameters' do
    setup do
      get :index, :theme => {:id => ''}, :study => {:id => ''}, :person => {:id => ''},
          :keyword_list => '', :date => {:syear => '1988', :eyear => Date.today.year.to_s}, :commit => 'Search'
    end
  
    should_assign_to :datasets
    should_assign_to :people
    should_assign_to :themes
    should_assign_to :studies
        
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
  end
  
  
  context 'GET index with theme search' do
    setup do 
      @theme = Factory.create(:theme, :id => 1)
      get :index, :theme => {:id => '1'}
    end
    
    should_assign_to :datasets
    should_assign_to :people
    should_assign_to :themes
    should_assign_to :studies
    should_assign_to :theme
         
     should 'have the right theme' do
       assert @theme == assigns(:theme)
     end
     
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
  end
  
  context 'GET with date search' do
    setup do 
      get :index, :date => {:syear => 2000, :eyear => 2003}
    end
    
    should_assign_to :datasets
    should_assign_to :people
    should_assign_to :themes
    should_assign_to :studies
        
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
    
  end
  
  context 'GET with study search' do
    setup do
      @study = Factory.create(:study)
      Factory.create(:dataset, :studies => [@study])
      Factory.create(:dataset, :studies => [Factory.create(:study)])
      get :index, :study => {:id => @study.id.to_s}
  end
    
    should_assign_to :datasets
    should_assign_to :people
    should_assign_to :themes
    should_assign_to :studies
   
    should 'have only one study' do
      assert [@study] == assigns(:studies)
    end
   
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
  end
    
  context 'eml harvester document' do
    setup do
      @dataset = Factory.create(:dataset)
      get :index, :format => :eml
    end
    
    should 'be succesful'
  end
end
