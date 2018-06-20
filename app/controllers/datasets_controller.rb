# Datasets are the core of the system
# manages the display and editing of the datasets
# we have not used it to create and delete datasets
class DatasetsController < ApplicationController
  helper_method :dataset

  before_action :require_login, except: %i[index show]
  before_action :allow_on_web, except: %i[knb]
  before_action :admin?, except: %i[index show]

  # layout proc { |controller| controller.request.format == :eml ? false : 'application' }

  # POST /dataset
  def upload
    @dataset = Dataset.new
  end

  # GET /datasets
  # GET /datasets.xml
  def index
    request.format  = :eml if params[:Dataset]
    @keyword_list   = params['keyword_list']
    @people         = Person.find_all_with_dataset
    @themes         = Theme.by_weight
    @datasets       = Dataset.where(on_web: true).where(website_id: website.id)
    @studies        = collect_and_normalize_studies(@datasets)
    @crumbs         = []
    respond_to do |format|
      format.html { redirect_to datatables_path unless params[:really] }
      format.xml  { render xml: @datasets.to_xml }
      format.eml { render eml: @datasets }
    end
  end

  # GET /datasets/1
  # GET /datasets/1.xml
  # GET /dataset/1.eml
  def show
    @title = dataset.title

    if dataset.valid_request?(@subdomain_request)
      respond_with dataset do |format|
        format.eml { render xml: dataset.to_eml }
        # format.eml { render eml:@dataset }
      end
    else
      redirect_to datasets_url
    end
  end

  def knb
    _scope, identifier = params[:id].split(/\./)
    dataset = Dataset.where(metacat_id: identifier).first
    dataset = Dataset.where(id: identifer).first unless dataset
    redirect_to dataset
  end

  # GET /datasets/new
  def new
    @dataset = Dataset.new
  end

  # GET /datasets/1;edit
  def edit
    @people = Person.by_sur_name
    @studies = Study.by_weight
    @themes = Theme.by_weight
    @roles = dataset_roles
    @websites = Website.all.collect { |website| [website.name, website.id] }
    @sponsors = Sponsor.all.collect { |sponsor| [sponsor.name, sponsor.id] }
  end

  # POST /dataset/new_affiliation
  def set_affiliation_for
    @affiliation = Affiliation.new
    people = Person.by_sur_name_asc
    roles = dataset_roles

    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.insert_html :bottom, 'affiliations',
                           partial: 'affiliation',
                           locals: { roles: roles, people: people,
                                     affiliation: @affiliation }
        end
      end
    end
  end

  # POST /datasets
  def create
    @dataset = if params[:eml_link].present?
                 Dataset.from_eml(params[:eml_link])
               elsif params[:dataset][:eml_file].present?
                 Dataset.from_eml_file(params[:dataset][:eml_file])
               else
                 Dataset.new(dataset_params)
               end

    unless @dataset.class == Dataset # if not a Dataset, it will be an array of errors
      flash[:notice] = 'Eml import had errors: ' + @dataset.collect(&:to_s).join(' ')
      @dataset = Dataset.new
    end
    if @dataset.save
      # loop over the files.
      # params[:files].each do |file|
      #   @dataset.dataset_files.create(data: file)
      # end
      flash[:notice] = 'Dataset was successfully created.'
    end

    respond_with @dataset
  end

  # PUT /datasets/1
  def update
    if dataset.update_attributes(dataset_params)
      # params[:files].each do |file|
      #   dataset.dataset_files.create(data: file)
      # end

      flash[:notice] = 'Dataset was successfully updated.'
    end
    respond_with dataset
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
    @title = 'LTER Datasets'
  end

  def set_crumbs
    crumb = Struct::Crumb.new
    @crumbs = []
    crumb.url = datasets_path
    crumb.name = 'Data Catalog: Datasets'
    @crumbs << crumb
  end

  def allow_on_web
    dataset_id = params[:id]
    return unless dataset_id
    if dataset_id =~ /KBS\d\d\d/
      dataset_id = Dataset.find_by(dataset: dataset_id)
    end
    dataset = Dataset.find(dataset_id)
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
    @studies.sort_by!(&:weight)
  end

  def dataset
    Dataset.find(params[:id])
  end

  def dataset_params
    params.require(:dataset).permit(:dataset, :title, :abstract, :status,
                                    :initiated, :completed, :released,
                                    :on_web, :core_dataset, :project_id,
                                    :metacat_id, :sponsor_id, :website_id,
                                    :keyword_list, affiliations_attributes: [],
                                    dataset_files_attributes: [:name, :data, :_destroy, :id])
  end

  def dataset_roles
    Role.where(role_type_id: RoleType.where(name: 'lter_dataset').first)
  end
end
