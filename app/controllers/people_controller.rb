class PeopleController < ApplicationController
  
  layout :site_layout
  
  before_filter :admin?, :except => [:index, :show, :alphabetical, :emeritus] unless ENV["RAILS_ENV"] == 'development'
  before_filter :get_person, :only => [:show, :edit, :update, :destroy]
  before_filter :get_people, :only => [:index, :alphabetical, :emeritus, :show_all]
  
  caches_action :index

  # GET /people
  # GET /people.xml
  def index
    @roles = RoleType.find_by_name('lter').roles.all(:order => :seniority, :conditions =>['name not like ?','Emeritus%'])
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @people.to_xml }
    end
  end  
  
  def alphabetical
    @title = 'KBS LTER Directory (alphabetical)'
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @people.to_xml }
    end
  end  
  
  def emeritus
    @roles = RoleType.find_by_name('lter').roles.all(:order => :seniority, :conditions =>['name like ?','Emeritus%'])
    respond_to do |format|
      format.html # emeritus.rhtml
      format.xml  { render :xml => @people.to_xml }
    end
    
  end

  def show_all
  end
  
  # GET /people/1
  # GET /people/1.xml
  def show
    respond_to do |format|
      format.html { render_subdomain }
      format.xml  { render :xml => @person.to_xml }
    end
  end

  # GET /people/new
  def new
    @person = Person.new
    @roles = Role.find_all_by_role_type_id(RoleType.find_by_name('lter'))
  end

  # GET /people/1;edit
  def edit
    @title = 'Edit ' + @person.full_name
    @roles = Role.find_all_by_role_type_id(RoleType.find_by_name('lter'))
  end

  # POST /people
  # POST /people.xml
  def create
    @person = Person.new(params[:person])
     
    respond_to do |format|
      if @person.save
        expire_action :action => :index
        flash[:notice] = 'Person was successfully created.'
        format.html { redirect_to person_url(@person) }
        format.xml  { head :created, :location => person_url(@person) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @person.errors.to_xml }
      end
    end
  end

  # PUT /people/1
  # PUT /people/1.xml
  def update    
    expire_page :action => :index
    
    respond_to do |format|
      if @person.update_attributes(params[:person])
        expire_action :action => :index
        flash[:notice] = 'Person was successfully updated.'
        format.html { redirect_to person_url(@person) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @person.errors.to_xml }
      end
    end
  end

  # DELETE /people/1
  # DELETE /people/1.xml
  def destroy
    @person.destroy

    expire_action :action => :index
    respond_to do |format|
      format.html { redirect_to people_url }
      format.xml  { head :ok }
    end
  end
  
  private 
  def set_title
    if @subdomain_request == "lter"
      @title = 'KBS LTER Directory'
    else
      @title = 'GLBRC Directory'
    end
  end
  
  def get_people
    @people = Person.all(:order => 'sur_name')
  end
  
  def get_person
    @person = Person.find(params[:id])
  end
end
