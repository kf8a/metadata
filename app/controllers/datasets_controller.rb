class DatasetsController < ApplicationController

  layout :site_layout
  
  before_filter :allow_on_web, :except => [:autocomplete_for_keyword_list]
  before_filter :admin?, :except => [:index, :show, :auto_complete_for_keyword_list] if Rails.env == 'production'
  before_filter :get_dataset, :only => [:show, :edit, :update, :destroy]
  
  #layout proc {|controller| controller.request.format == :eml ? false : 'application'}
  
  # POST /dataset
  def upload
    file = params[:file]
    @dataset = Dataset.new
  end
  
  # GET /datasets
  # GET /datasets.xml
  def index
    request.format  = :eml if params[:Dataset]
    @keyword_list   = params['keyword_list']
    @people         = Person.find_all_with_dataset
    @themes         = Theme.by_weight
    @datasets       = Dataset.all
    @studies        = collect_and_normalize_studies(@datasets)
    @studies        = [@study] if @study
    @crumbs         = []
    respond_to do |format|
      format.html {redirect_to datatables_path}
      format.xml  { render :xml => @datasets.to_xml }
      format.eml { render :eml => @datasets }
    end
  end

  # GET /datasets/1
  # GET /datasets/1.xml
  # GET /dataset/1.eml
  def show
    @title    = @dataset.title

    if @dataset.valid_request?(@subdomain_request)
      respond_to do |format|
        format.html { render_subdomain }
        format.eml { render :xml => @dataset.to_eml }
        format.xml  { render :xml => @dataset.to_xml }
      end
    else
      redirect_to datasets_url
    end
  end

  # GET /datasets/new
  def new
    @dataset = Dataset.new
  end

  # GET /datasets/1;edit
  def edit
    @people   = Person.by_sur_name
    @studies = Study.by_weight
    @themes = Theme.by_weight
    @roles  = Role.find_all_by_role_type_id(RoleType.find_by_name('lter_dataset'))
    @websites = Website.all.collect {|x| [x.name, x.id]}
    @sponsors = Sponsor.all.collect {|x| [x.name, x.id]}
  end
  
  # POST /dataset/new_affiliation 
  def set_affiliation_for
    @affiliation = Affiliation.new
    people = Person.by_sur_name_asc
    roles = Role.find_all_by_role_type_id(RoleType.find_by_name('lter_dataset'))
    
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.insert_html :bottom, 'affiliations', 
            :partial  => "affiliation", 
            :locals   => {:roles        => roles, 
                          :people       => people, 
                          :affiliation  => @affiliation}
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
    @sponsors = Sponsor.all.collect {|x| [x.name, x.id]}
    @websites = Website.all.collect {|x| [x.name, x.id]}
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
    @dataset.destroy

    respond_to do |format|
      format.html { redirect_to datasets_url }
      format.xml  { head :ok }
    end
  end
  
  def auto_complete_for_keyword_list
    tags = Tag.order('name ASC').where('name LIKE ?', '%' + params[:q] + '%')
    render :text => (tags.collect{|x| x.name}).join("\n")
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
    if params[:id] =~ /KBS\d\d\d/
      params[:id] = Dataset.find_by_dataset(params[:id])
    end
    dataset = Dataset.find(params[:id])
    dataset.on_web
  end
  
  def collect_and_normalize_studies(datasets)
    @studies = datasets.collect do |dataset|
      next unless dataset.on_web
      dataset.studies.flatten
    end
    @studies.flatten!
    @studies.compact!
    @studies.uniq!
    @studies.sort! {|a,b| a.weight <=> b.weight}
  end
  
  def get_dataset
    @dataset  = Dataset.find(params[:id])
  end
end
