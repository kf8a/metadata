require File.expand_path('../../test_helper', __FILE__)
# require 'abstracts_controller'

class AbstractsControllerTest < ActionController::TestCase
  def setup
    @meeting = FactoryBot.create(:meeting)

    # TODO: test with admin and non admin users
    signed_in_as_admin
  end

  def teardown
    Meeting.destroy_all
    Abstract.destroy_all
  end

  context 'on GET to :index' do
    setup do
      get :index
    end

    should render_template :index
  end

  context 'on GET to :new for a valid meeting' do
    setup do
      get :new, params: { meeting_id: @meeting.id }
    end

    should render_template :new
  end

  context 'on POST to :create for a valid abstract' do
    setup do
      post :create, params: { abstract: 'A valid abstract', meeting_id: @meeting.id }
    end

    # should redirect_to("the abstract page") {abstract_url(assigns(:abstract))}
    should set_flash
  end

  context 'on POST to :create for an invalid abstract' do
    setup do
      post :create, params: { abstract: { meeting_id: nil } }
    end

    should render_template :new
  end

  context 'on GET to :show for an abstract' do
    setup do
      @abstract = FactoryBot.create(:abstract)
      get :show, params: { id: @abstract }
    end

    should render_template :show
  end

  context 'on GET to :edit for an abstract' do
    setup do
      @abstract = FactoryBot.create(:abstract)
      get :edit, params: { id: @abstract }
    end

    should render_template :edit
  end

  context 'on PUT :update for an abstract' do
    setup do
      @abstract = FactoryBot.create(:abstract, abstract: 'The old boring abstract')
    end

    context 'with a valid change' do
      setup do
        put :update, params: { id: @abstract, abstract: { abstract: 'A whole new abstract' } }
      end

      should set_flash
      should redirect_to("the abstract's show page") { abstract_url(@abstract) }
    end
  end

  context 'an abstract which exists' do
    setup do
      @abstract = FactoryBot.create(:abstract)
    end

    context 'on DELETE :destroy for the abstract' do
      setup do
        delete :destroy, params: { id: @abstract }
      end

      should redirect_to('meetings page') { meetings_url }
    end
  end
end
