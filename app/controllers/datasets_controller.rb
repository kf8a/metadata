class DatasetsController < ApplicationController

  before_filter :allow_on_web
  before_filter :admin?, :except => [:index, :show ] if Rails.env == 'production'
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
    @datasets       = Dataset.where(:on_web => true).where(:website_id => website.id)
    @studies        = collect_and_normalize_studies(@datasets)
    @crumbs         = []
    respond_to do |format|
      format.html {redirect_to datatables_path unless params[:really]}
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
      respond_with @dataset do |format|
        format.eml { render :xml => @dataset.to_eml }
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
    @websites = Website.all.collect {|website| [website.name, website.id]}
    @sponsors = Sponsor.all.collect {|sponsor| [sponsor.name, sponsor.id]}
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
    if params[:eml_link].present?
      @dataset = Dataset.from_eml(params[:eml_link])
    elsif params[:dataset][:eml_file].present?
      @dataset = Dataset.from_eml_file(params[:dataset][:eml_file])
    else
      @dataset = Dataset.new(params[:dataset])
    end
    unless @dataset.class == Dataset #if not a Dataset, it will be an array of errors
      flash[:notice] = "Eml import had errors: " + @dataset.collect{|error| error.to_s}.join(' ')
      @dataset = Dataset.new
    end
    if @dataset.save
      flash[:notice] = 'Dataset was successfully created.'
    end
    respond_with @dataset
  end

  # PUT /datasets/1
  # PUT /datasets/1.xml
  def update
    @sponsors = Sponsor.all.collect {|sponsor| [sponsor.name, sponsor.id]}
    @websites = Website.all.collect {|website| [website.name, website.id]}
    if @dataset.update_attributes(params[:dataset])
      flash[:notice] = 'Dataset was successfully updated.'
    end
    respond_with @dataset
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
    @studies.sort_by! { |study| study.weight }
  end

  def get_dataset
    @dataset  = Dataset.find(params[:id])
  end
end
