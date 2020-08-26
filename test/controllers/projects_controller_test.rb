require File.expand_path('../../test_helper',__FILE__)

class ProjectsControllerTest < ActionController::TestCase

  def setup
    # TODO: test with non admin users
    signed_in_as_admin
  end

  def teardown
    Project.destroy_all
  end

  context 'on GET to :index' do
    setup do
      get :index
    end

    should render_template :index
  end

  context 'on GET to :show for a project' do
    setup do
      @project = FactoryBot.create(:project)
      get :show, params: { id: @project }
    end

    should render_template :show
  end

  context 'on GET to :new' do
    setup do
      get :new
    end

    should render_template :new
  end

  context 'on GET to :edit for a project' do
    setup do
      @project = FactoryBot.create(:project)
      get :edit, params: { id: @project }
    end

    should render_template :edit
  end

  context 'on POST to :create for a valid project' do
    setup do
      post :create, params: { project: { title: 'New project' } }
    end

    should redirect_to("the project's page") { project_url(assigns(:project))}
    should set_flash
  end

  # A test should be made for trying to create an invalid project once invalid projects are possible.

  context 'on PUT :update for a project' do
    setup do
      @project = FactoryBot.create(:project, title: 'The old boring title')
    end

    context 'with a valid change' do
      setup do
        put :update, params: { id: @project, project: { title: 'A new title' } }
      end

      should set_flash
      should redirect_to("the project's show page") { project_url(@project) }
    end
  end

  # A test should be made trying to update with an invalid change if any invalid parameters are ever adopted.

  context 'a project which exists' do
    setup do
      @project = FactoryBot.create(:project)
    end

    context 'on DELETE :destroy for the project' do
      setup do
        delete :destroy, params: { id: @project }
      end

      should redirect_to('projects page') { projects_url }
    end
  end
end
