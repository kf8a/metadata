# Handle display of projects
# TODO: Do we need to keep this since we don't use it
class ProjectsController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :admin?, except: [:index, :show]
  before_action :project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  # GET /projects.xml
  def index
    @projects = Project.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render xml: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render xml: @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = Project.new
    @datasets = Dataset.all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render xml: @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @datasets = Dataset.all
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = Project.new(project_params)
    flash[:notice] = 'Project was successfully created.' if @project.save
    respond_with @project
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    if @project.update_attributes(project_params)
      flash[:notice] = 'Project was successfully updated.'
    end
    respond_with @project
  end

  # DELETE /projects/1
  # DELETE /projects/1.xml
  def destroy
    @project.destroy

    respond_to do |format|
      format.html { redirect_to(projects_url) }
      format.xml  { head :ok }
    end
  end

  private

  def project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :abstract)
  end
end
