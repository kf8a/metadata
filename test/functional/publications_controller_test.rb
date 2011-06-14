require File.expand_path('../../test_helper',__FILE__) 

class PublicationsControllerTest < ActionController::TestCase
 fixtures :publications, :treatments

  def setup
    #TODO test with admin and non admin users
    @controller.current_user = Factory.create :admin_user
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:publications)
  end
  
  context "GET :index with params[:alphabetical]" do
    setup do
      get :index, :alphabetical => true
    end
    
    should assign_to(:alphabetical).with(true)
    should assign_to(:decoration).with("by Author")
  end

  context "GET :index with params[:treatment]" do
    setup do
      get :index, :treatment => true
    end
    
    should assign_to(:alphabetical).with(true)
  end
  
  context "GET :index with params[:word]" do
    setup do
      get :index, :word => 'something'
    end
    
    should assign_to :publications
  end
  
  context "GET :index_by_treatment" do
    setup do
      get :index_by_treatment
    end
    
    should assign_to :studies
  end
  
  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_publication
    old_count = Publication.count
    post :create, :publication => {'year' => '2008', :citation => 'Jones et.al 2008'}
    assert_equal (old_count+1), Publication.count
    assert_redirected_to publication_path(assigns(:publication))
  end
  
  context "POST :create with invalid parameters" do
    setup do
      post :create, :publication => {:citation => nil}
    end
    
    should_not set_the_flash
    should render_template :new
  end

  def test_should_show_publication
    get :show, :id => 135
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 135
    assert_response :success
  end
  
  def test_should_update_publication
    put :update, :id => 18, :publication => {'year' => '2008'} 
    assert_redirected_to publication_path(assigns(:publication))
  end
  
  context "PUT :update with invalid parameters" do
    setup do
      @publication = Factory.create(:publication)
      put :update, :id => @publication, :publication => {:citation => nil}
    end
    
    should_not set_the_flash
    should render_template :edit
    should assign_to :publication_types
    should assign_to :treatments
    should assign_to :publication
  end

  context 'POST adding treatments' do
    setup do
      @publication = Factory.create(:publication)
      @treatment = Factory.create(:treatment)
      post :update, :id => @publication, :publication => {:treatment_ids => [@treatment.id]}
    end

    should assign_to :publication

    should 'have the treatment attached' do
      assert @publication.treatments.include?(@treatment)
    end
  end

  context 'POST removing treatments' do
    setup do
      @publication = Factory.create(:publication)
      @publication.treatments  << Factory.create(:treatment)
      post :update, :id => @publication, :publication => {:treatment_ids => []}
    end

    should assign_to :publication

    should 'not have the treatment attached' do
      assert_equal 0,  @publication.treatments.size
    end
  end
  
  def test_should_destroy_publication
    @publication = Factory.create(:publication)
    old_count = Publication.count
    delete :destroy, :id => @publication
    assert_equal old_count-1, Publication.count
    
    assert_redirected_to publications_path
  end

  context 'A publication exists. ' do
    setup do
      @publication = Factory.create(:publication)
    end

    context 'DELETE :destroy the publication in javascript' do
      setup do
        xhr :delete, :destroy, :id => @publication
      end

      should respond_with(:success)
    end
  end
end
