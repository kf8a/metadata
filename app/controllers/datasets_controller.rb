class DatasetsController < ApplicationController
      
  before_filter :set_title, :allow_on_web
  
  # POST /dataset
  def upload
    file = params[:file]
    @dataset = Dataset.new
  end
  
  # GET /datasets
  # GET /datasets.xml
  def index
    theme = params[:theme] || ''
    person = params[:person] || ''
    @person = nil
    @people = Person.find_all_with_dataset
    
    @themes = Theme.find(:all, :order => :priority)
    unless theme.empty? || theme[:id].empty?
        @theme = Theme.find(theme[:id])
        @themes = [@theme]
    end
    @datasets = Dataset.find(:all)
    unless person.empty? || person[:id].empty?
      @person = Person.find(person[:id])
      @datasets = Dataset.find(:all, :joins => :people, :conditions => {:people => {:id => @person  }})
      @datasets.uniq!
   end
    @crumbs = []
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @datasets.to_xml }
    end
  end

  # GET /datasets/1
  # GET /datasets/1.xml
  # GET /dataset/1.eml
  def show
    @dataset = Dataset.find(params[:id])
    @title = @dataset.title
    @roles = @dataset.roles

    respond_to do |format|
      format.html # show.rhtml
      format.eml { render :xml => @dataset.to_eml }
      format.xml  { render :xml => @dataset.to_xml }
    end
  end

  # GET /datasets/new
  def new
    @dataset = Dataset.new
  end

  # GET /datasets/1;edit
  def edit
    @dataset = Dataset.find(params[:id])
    @people = Person.all
    @roles = Role.find(:all, :conditions => ['role_type_id = ?', RoleType.find_by_name('dataset')])
  end
  
  # POST /dataset/new_affiliation 
  def set_affiliation_for
    @affiliation = Affiliation.new
    people = Person.all
    roles = Role.find(:all, :conditions => ['role_type_id = ?', RoleType.find_by_name('dataset')])
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.insert_html :bottom, 'affiliations', :partial => "affiliation", 
            :locals => {:roles => roles, :people => people}
        end
      end
    end
    
  end

  # POST /datasets
  # POST /datasets.xml
  def create
    @dataset = Dataset.new(params[:dataset])

    respond_to do |format|
      if @dataset.save
        flash[:notice] = 'Dataset was successfully created.'
        format.html { redirect_to dataset_url(@dataset) }
        format.xml  { head :created, :location => dataset_url(@dataset) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @dataset.errors.to_xml }
      end
    end
  end

  # PUT /datasets/1
  # PUT /datasets/1.xml
  def update
    @dataset = Dataset.find(params[:id])

    respond_to do |format|
      if @dataset.update_attributes(params[:dataset])
        flash[:notice] = 'Dataset was successfully updated.'
        format.html { redirect_to dataset_url(@dataset) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @dataset.errors.to_xml }
      end
    end
  end

  # DELETE /datasets/1
  # DELETE /datasets/1.xml
  def destroy
    @dataset = Dataset.find(params[:id])
    @dataset.destroy

    respond_to do |format|
      format.html { redirect_to datasets_url }
      format.xml  { head :ok }
    end
  end
  
  private
  def set_title
    @title  = 'LTER Datasets'
  end

  def set_crumbs
    crumb = Struct::Crumb.new
    @crumbs = []
    crumb.url = datasets_path
    crumb.name = 'Data Catalog: Datasets'
    @crumbs << crumb
  end
  
  def allow_on_web
    return unless params[:id]
    dataset = Dataset.find(params[:id])
    dataset.on_web
  end
end
