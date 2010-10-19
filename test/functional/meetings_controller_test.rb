require File.expand_path('../../test_helper',__FILE__) 

# Re-raise errors caught by the controller.
class MeetingsController; def rescue_action(e) raise e end; end

class MeetingsControllerTest < ActionController::TestCase

  def setup

    #TODO test with admin and non admin users
    @controller.current_user = Factory.create :admin_user
  end

  def teardown
    Meeting.destroy_all
  end
  
  context "on GET to :index" do
    setup do
      get :index
    end

    should assign_to :venue
    should assign_to :meetings
    should assign_to :title
    should render_template :index
  end

  context "on GET to :show for a meeting" do
    setup do
      @meeting = Factory.create(:meeting)
      get :show, :id => @meeting
    end

    should assign_to :meeting
    should render_template :show
  end
  
  context "on GET to :new" do
    setup do
      get :new
    end

    should assign_to :meeting
    should assign_to :venues
    should render_template :new
  end
  
  context "on GET to :edit for a meeting" do
    setup do
      @meeting = Factory.create(:meeting)
      get :edit, :id => @meeting
    end
    
    should assign_to :meeting
    should assign_to :venues
    should render_template :edit
  end


  context "on POST to :create with valid parameters" do  
    setup do
      venue = Factory.create(:venue_type)
      post :create, :meeting => {:venue_type_id => venue.id}
    end
    
    should assign_to :meeting
    should redirect_to("the meetings page") {meetings_url}
    should set_the_flash
  end
  
  context "on POST to :create with invalid parameters" do
    setup do
      post :create, :meeting => {:venue_type_id => nil}
    end
    
    should assign_to :meeting
    should assign_to :venues
    should render_template :new
    should_not set_the_flash
  end

  context "on PUT :update for a meeting" do
    setup do
      @meeting = Factory.create(:meeting, :title => "The old boring title")
    end
    
    context "with a valid change" do
    
      setup do
        put :update, :id => @meeting, :meeting => {:title => "A whole new title"}
      end
    
      should set_the_flash
      should redirect_to("the meeting's show page") {meeting_url(@meeting)}
    end
    
    context "with an invalid change" do
    
      setup do
        put :update, :id => @meeting, :meeting => {:venue_type => nil}
      end
      
      should assign_to :venues
      should_not set_the_flash
      should render_template :edit
    end
  end
  
  context "a meeting which exists" do
    setup do
      @meeting = Factory.create(:meeting)
    end
    
    context "on DELETE :destroy for the abstract" do
      setup do
        delete :destroy, :id => @meeting
      end
      
      should redirect_to("meetings page") {meetings_url}
    end
  end

end
