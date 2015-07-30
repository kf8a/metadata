require File.expand_path('../../test_helper',__FILE__)

class MeetingsControllerTest < ActionController::TestCase

  def setup
    #TODO test with admin and non admin users
    signed_in_as_admin
    @venue_type = FactoryGirl.create :venue_type
    @meeting = FactoryGirl.create :meeting
    MeetingAbstractType.create(name: "Poster")
    @meeting.venue_type = @venue_type
  end

  def teardown
    Meeting.destroy_all
    MeetingAbstractType.destroy_all
  end

  context "on GET to :index" do
    setup do
      get :index
    end

    should render_template :index
  end

  context "on GET to :show for a meeting" do
    setup do
      @meeting = FactoryGirl.create :meeting
      get :show, :id => @meeting
    end

    should render_template :show
  end

  context "on GET to :new" do
    setup do
      get :new
    end

    should render_template :new
  end

  context "on GET to :edit for a meeting" do
    setup do
      @meeting = FactoryGirl.create :meeting
      get :edit, :id => @meeting
    end

    should render_template :edit
  end


  context "on POST to :create with valid parameters" do
    setup do
      venue = FactoryGirl.create :venue_type
      post :create, :meeting => {:venue_type_id => venue.id}
    end

    should redirect_to("the meetings page") {meetings_url}
    should set_flash
  end

  context "on POST to :create with invalid parameters" do
    setup do
      post :create, :meeting => {:venue_type_id => nil}
    end

    should render_template :new
    should_not set_flash
  end

  context "on PUT :update for a meeting" do
    setup do
      @meeting = FactoryGirl.create :meeting, :title => "The old boring title"
    end

    context "with a valid change" do

      setup do
        put :update, :id => @meeting, :meeting => {:title => "A whole new title"}
      end

      should set_flash
      should redirect_to("the meeting's show page") {meeting_url(@meeting)}
    end

  end

  context "a meeting which exists" do
    setup do
      @meeting = FactoryGirl.create(:meeting)
    end

    context "on DELETE :destroy for the abstract" do
      setup do
        delete :destroy, :id => @meeting
      end

      should redirect_to("meetings page") {meetings_url}
    end

    context "DELETE :destroy abstract, js format" do
      setup do
        xhr :delete, :destroy, :id => @meeting
      end

      should_not render_with_layout
      should_not respond_with(:redirect)
      should respond_with(:success)
    end
  end

end
