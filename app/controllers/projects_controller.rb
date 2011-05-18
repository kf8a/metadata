class ProjectsController < ApplicationController
  before_filter :admin?, :except => [:index, :show]  if Rails.env == 'production'
  before_filter :get_project, :only => [:show, :edit, :update, :destroy]
  
  # GET /projects
  # GET /projects.xml
  def index
    @projects = Project.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/new
  # GET /projects/new.xml
  def new
    @project = Project.new
    @datasets = Dataset.all

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @datasets = Dataset.all
  end

  # POST /projects
  # POST /projects.xml
  def create
    @project = Project.new(params[:project])
    if @project.save
      flash[:notice] = 'Project was successfully created.'
    end
    respond_with @project
  end

  # PUT /projects/1
  # PUT /projects/1.xml
  def update
    if @project.update_attributes(params[:project])
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
  
  def get_project
    @project = Project.find(params[:id])
  end
end
