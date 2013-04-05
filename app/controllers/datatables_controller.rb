class DatatablesController < ApplicationController
  helper_method :datatable

  before_filter :admin?, :except => [:index, :show, :suggest, :search, :qc] unless Rails.env == 'development'
  before_filter :can_download?, :only=>[:show], :if => Proc.new { |controller| controller.request.format.csv? } # run before filter to prevent non-members from downloading

  protect_from_forgery :except => [:index, :show, :search]
  cache_sweeper :datatable_sweeper

  # GET /datatables
  # GET /datatables.xml
  def index
    # expires_in 6.minutes, :public=>true
    store_location
    retrieve_datatables('keyword_list' =>'')

    if Rails.env == 'production' and stale? etag: @datatables
      respond_with @datatables do |format|
        format.rss {render :rss => @datatables}
      end
    end
  end

  def search
    query =  {'keyword_list' => ''}
    query.merge!(params)
    if query['keyword_list'].empty?
      redirect_to datatables_url
    else
      retrieve_datatables(query)
    end
  end

  # GET /datatables/1
  # GET /datatables/1.xml
  # GET /datatables/1.csv
  def show
    #expires_in 5.minutes
    @website = website

    store_location #in case we have to log in and come back here
    if datatable.dataset.valid_request?(@subdomain_request)
      if Rails.env=='production' and stale? etag: [datatable, current_user]
        respond_to do |format|
          format.html
          format.xml
  #         format.ods do
  #           if csv_ok
  #             render :text => @datatable.to_ods
  #           else
  #             redirect_to datatable_url(@datatable)
  #           end
  #         end
          format.csv do
            unless csv_ok
              render :text => "You do not have permission to download this datatable"
            end
            # render show.csv.erb
          end
          format.climdb do
            unless csv_ok
              redirect_to datatable_url(datatable)
            end
          end
        end
      end
    else
      redirect_to datatables_url
    end
  end

  def qc
  end

  # GET /datatables/new
  def new
    @core_areas = CoreArea.by_name.collect { |area| [area.name, area.id] }
    @studies = Study.all.collect{ |study| [study.name, study.id] }
    @people = Person.all
    @units = Unit.all
  end

  # GET /datatables/1;edit
  def edit
    @core_areas = CoreArea.by_name.collect { |area| [area.name, area.id] }
    @studies = Study.all.collect{ |study| [study.name, study.id] }
    @people = Person.all
    # @units = Unit.order(:name).all
  end

  # POST /datatables
  # POST /datatables.xml
  def create
    @core_areas = CoreArea.by_name.collect { |area| [area.name, area.id] }
    @studies = Study.all.collect{ |study| [study.name, study.id] }
    @people = Person.all
    @units = Unit.all

    if datatable.save
      flash[:notice] = 'Datatable was successfully created.'
    end

    respond_with datatable
  end

  # PUT /datatables/1
  # PUT /datatables/1.xml
  def update
    @core_areas = CoreArea.by_name.collect { |area| [area.name, area.id] }
    @studies = Study.all.collect{ |study| [study.name, study.id]}
    @people = Person.all
    @units = Unit.all

    if datatable.update_attributes(params[:datatable])
      flash[:notice] = 'Datatable was successfully updated.'
    end

    respond_with datatable
  end

  # DELETE /datatables/1
  # DELETE /datatables/1.xml
  def destroy
    datatable.destroy
    respond_with datatable
  end

  #TODO only return the ones for the right website.
  def suggest
    term = params[:term]

    list = ActsAsTaggableOn::Tag.where("lower(name) like ?", term.downcase + '%').select("DISTINCT tags.name")
    list = list + Person.where('lower(sur_name) like ?', term.downcase + '%').select('DISTINCT sur_name as name')
    list = list + Theme.where('lower(name) like ?', term.downcase + '%').select('DISTINCT name')
    list = list + CoreArea.where('lower(name) like ?', term.downcase + '%').select('DISTINCT name')

    keywords = list.collect {|x| x.name.downcase }.sort.uniq
    respond_to do |format|
      format.json {render :json => keywords}
    end
  end

  def update_temporal_extent
    datatable.update_temporal_extent
    datatable.save
    #TODO write test to make sure the js fragment get's rendered
    respond_to do |format|
      format.json 
      format.html {render :nothing => true}
    end
  end

  def approve_records
    datatable.approve_data
    datatable.save
    redirect_to edit_datatable_path(datatable)
  end

  private

  def set_title
    if @subdomain_request == 'lter'
      @title  = 'LTER Data Catalog'
    else
      @title = 'GLBRC Sustainability Data Catalog'
    end
  end

  def set_crumbs
    crumb = Struct::Crumb.new
    @crumbs = []

    crumb.url = '/datatables/'
    crumb.name = 'Data Catalog'
    @crumbs << crumb
    crumb = Struct::Crumb.new

    return unless params[:id]

    datatable  = Datatable.find(params[:id])

    if datatable.study
      study = datatable.study
      #crumb.url = study_path(study)
      crumb.name = study.name
      @crumbs << crumb
    end
    # crumb = Struct::Crumb.new
    #
    # crumb.url =  dataset_path(datatable.dataset)
    # crumb.name = datatable.dataset.title
    # @crumbs << crumb

  end

  def retrieve_datatables(query)
    @default_value = 'Search for core areas, keywords or people'
    @themes = Theme.roots

    @keyword_list = query['keyword_list']
    @keyword_list = nil if @keyword_list.empty? || @keyword_list == @default_value

    @datatables =
      if @keyword_list
        Datatable.search @keyword_list, :with => {:website => website.id}
      else
        Datatable.where(:on_web => true).
            joins('left join datasets on datasets.id = datatables.dataset_id').
            where('is_secondary is false and website_id = ?', website.id)
      end

    @studies = Study.find_all_roots_with_datatables(@datatables)
  end

  def datatable
    @datatable ||= params[:id] ? Datatable.find(params[:id]) : Datatable.new(params[:datatable])
  end

  def csv_ok
    datatable.can_be_downloaded_by?(current_user)
  end

  def can_download?
    unless csv_ok
      head :forbidden
      return false
    end
  end
end
