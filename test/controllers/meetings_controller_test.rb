# frozen_string_literal: true

require File.expand_path('../../test_helper',__FILE__)

class MeetingsControllerTest < ActionController::TestCase
  def setup
    # TODO: test with admin and non admin users
    signed_in_as_admin
    @venue_type = FactoryBot.create :venue_type
    @meeting = FactoryBot.create :meeting
    MeetingAbstractType.create(name: "Poster")
    @meeting.venue_type = @venue_type
  end

  # def teardown
  #   Meeting.destroy_all
  #   MeetingAbstractType.destroy_all
  # end

  context "on GET to :index" do
    setup do
      get :index
    end

    should render_template :index
  end

  context "on GET to :show for a meeting" do
    setup do
      @meeting = FactoryBot.create :meeting
      get :show, params: { id: @meeting }
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
      @meeting = FactoryBot.create :meeting
      get :edit, params: { id: @meeting }
    end

    should render_template :edit
  end

  context "on POST to :create with valid parameters" do
    setup do
      venue = FactoryBot.create :venue_type
      post :create, params: { meeting: { venue_type_id: venue.id } }
    end

    should redirect_to("the meetings page") { meetings_url }
    should set_flash
  end

  context "on POST to :create with invalid parameters" do
    setup do
      post :create, params: { meeting: { venue_type_id: nil } }
    end

    should render_template :new
    should_not set_flash
  end

  context "on PUT :update for a meeting" do
    setup do
      @meeting = FactoryBot.create :meeting, title: "The old boring title"
    end

    context "with a valid change" do
      setup do
        put :update, params: { id: @meeting, meeting: { title: "A whole new title" } }
      end

      should set_flash
      should redirect_to("the meeting's show page") { meeting_url(@meeting) }
    end
  end

  context "a meeting which exists" do
    setup do
      @meeting = FactoryBot.create(:meeting)
    end

    context "on DELETE :destroy for the abstract" do
      setup do
        delete :destroy, params: { id: @meeting }
      end

      should redirect_to("meetings page") { meetings_url }
    end

    context "DELETE :destroy abstract, js format" do
      setup do
        post :delete, xhr: true, params: { id: @meeting, destroy: true }
      end

      should_not render_with_layout
      should_not respond_with(:redirect)
      should respond_with(:success)
    end
  end
end
