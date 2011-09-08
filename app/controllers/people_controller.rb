class PeopleController < ApplicationController
  
  before_filter :admin?, :except => [:index, :show, :alphabetical, :emeritus] unless Rails.env == 'development'
  before_filter :get_person, :only => [:show, :edit, :update, :destroy]
  before_filter :get_people, :only => [:index, :alphabetical, :emeritus, :show_all]
  
  cache_sweeper :people_sweeper
  caches_action :index, :alphabetical, :emeritus

  # GET /people
  # GET /people.xml
  def index
    expires_in 60.minutes, :public=>true

    @roles = RoleType.find_by_name('lter').roles.order('seniority').where('name not like ?','Emeritus%')
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
    @roles = RoleType.find_by_name('lter').roles.order('seniority').where('name like ?','Emeritus%')
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
    respond_with @person
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
    if @person.save
      flash[:notice] = 'Person was successfully created.'
    end
    respond_with @person
  end

  # PUT /people/1
  # PUT /people/1.xml
  def update    
    if @person.update_attributes(params[:person])
      flash[:notice] = 'Person was successfully updated.'
    end
    respond_with @person
  end

  # DELETE /people/1
  # DELETE /people/1.xml
  def destroy
    @person.destroy

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
    @people = Person.by_sur_name
  end
  
  def get_person
    @person = Person.find(params[:id])
  end
end
