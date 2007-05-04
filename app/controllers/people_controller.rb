class PeopleController < ApplicationController
      
  skip_filter :login_required, :only => ['alphabetical','show','index']

  # GET /people
  # GET /people.xml
  def index
    @people = Person.find(:all, :order => 'sur_name', :order => 'sur_name')
    @title = 'LTER People'
    @roles = RoleType.find_by_name('lter').roles.find(:all, :order => :seniority)
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @people.to_xml }
    end
  end  
  
  def alphabetical
    @people = Person.find(:all, :order => 'sur_name')
    @title = 'LTER People (alphabetical)'
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @people.to_xml }
    end
  end  


  # GET /people/1
  # GET /people/1.xml
  def show
    @person = Person.find(params[:id])
    @title = @person.full_name
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @person.to_xml }
    end
  end

  # GET /people/new
  def new
    @person = Person.new
    @title = 'New Person'
    @roles = Role.find(:all, :conditions => ['role_type_id = ?', RoleType.find_by_name('lter')])
  end

  # GET /people/1;edit
  def edit
    @person = Person.find(params[:id])
    @title = 'Edit ' + @person.full_name
    @roles = Role.find(:all, :conditions => ['role_type_id = ?', RoleType.find_by_name('lter')])
  end

  # POST /people
  # POST /people.xml
  def create
    @person = Person.new(params[:person])

    respond_to do |format|
      if @person.save
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
    @person = Person.find(params[:id])

    respond_to do |format|
      if @person.update_attributes(params[:person])
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
    @person = Person.find(params[:id])
    @person.destroy

    respond_to do |format|
      format.html { redirect_to people_url }

      format.xml  { head :ok }
    end
  end
end
