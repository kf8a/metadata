require File.expand_path('../../test_helper',__FILE__) 
require 'abstracts_controller'

class AbstractsControllerTest < ActionController::TestCase

  def setup
    @meeting = Factory.create(:meeting)
    
    #TODO test with admin and non admin users
    @controller.current_user = Factory.create :admin_user
  end
  
  def teardown
    Meeting.destroy_all
    Abstract.destroy_all
  end
  
  context "on GET to :index" do
    setup do
      get :index
    end
    
    should render_template :index
  end
  
  context "on GET to :new for a valid meeting" do
    setup do
      get :new, :meeting => @meeting
    end

    should render_template :new
  end

  context "on POST to :create for a valid abstract" do  
    setup do
      post :create, :abstract => {:abstract => 'A valid abstract', :meeting_id => @meeting.id}
    end
    
    should redirect_to("the abstract's meeting page") {meeting_url(@meeting)}
    should set_the_flash
  end
  
  context "on POST to :create for an invalid abstract" do
    setup do
      post :create, :abstract => {:meeting_id => nil}
    end
    
    should render_template :new
  end

  context "on GET to :show for an abstract" do
    setup do
      @abstract = Factory.create(:abstract)
      get :show, :id => @abstract
    end

    should render_template :show
  end
  
  context "on GET to :edit for an abstract" do
    setup do
      @abstract = Factory.create(:abstract)
      get :edit, :id => @abstract
    end
    
    should render_template :edit
  end
  
  context "on PUT :update for an abstract" do
    setup do
      @abstract = Factory.create(:abstract, :abstract => "The old boring abstract")
    end
    
    context "with a valid change" do
    
      setup do
        put :update, :id => @abstract, :abstract => {:abstract => "A whole new abstract"}
      end
    
      should set_the_flash
      should redirect_to("the abstract's show page") {abstract_url(@abstract)}
    end
    
    context "with an invalid change" do
    
      setup do
        put :update, :id => @abstract, :abstract => {:abstract => nil}
      end
      
      should_not set_the_flash
      should render_template :edit
    end
  end
  
  context "an abstract which exists" do
    setup do
      @abstract = Factory.create(:abstract)
    end
    
    context "on DELETE :destroy for the abstract" do
      setup do
        delete :destroy, :id => @abstract
      end
      
      should redirect_to("meetings page") {meetings_url}
    end
  end
  
end

