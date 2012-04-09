class DatatablesController < ApplicationController
  helper_method :datatable

  before_filter :admin?, :except => [:index, :show, :suggest, :search, :events, :qc] unless Rails.env == 'development'
  before_filter :can_download?, :only=>[:show], :if => Proc.new { |controller| controller.request.format.csv? } # run before filter to prevent non-members from downloading

  protect_from_forgery :except => [:index, :show, :search]
  cache_sweeper :datatable_sweeper

  # GET /datatables
  # GET /datatables.xml
  def index
    expires_in 60.minutes, :public=>true
    store_location
    retrieve_datatables('keyword_list' =>'')

    respond_with @datatables do |format|
      format.rss {render :rss => @datatables}
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

  def events
    datatable = Datatable.find(params[:id])
    render :json => datatable.events
  end

  # GET /datatables/1
  # GET /datatables/1.xml
  # GET /datatables/1.csv
  def show
    expires_in 5.minutes
#    accessible_by_ip = trusted_ip? || !datatable.is_restricted
#    csv_ok = accessible_by_ip && datatable.can_be_downloaded_by?(current_user)
#    csv_ok = datatable.can_be_downloaded_by?(current_user)
    @website = website

    store_location #in case we have to log in and come back here
    if datatable.dataset.valid_request?(@subdomain_request)
      if stale? etag: datatable
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
  # TODO renable after we have a common place for this cache
  #            file_cache = ActiveSupport::Cache.lookup_store(:file_store, 'tmp/cache')
  #            render :text => file_cache.fetch("csv_#{@datatable.id}") { @datatable.to_csv }
            unless csv_ok
              render :text => "You do not have permission to download this datatable"
            end
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
    @units = Unit.all
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
    #  list = Datatable.tags.all.collect {|x| x.name.downcase}
    list = Person.find_all_with_dataset.collect { |person| person.sur_name.downcase }
    list = list + Theme.all.collect { |theme| theme.name.downcase }
    list = list + CoreArea.all.collect { |area| area.name.downcase }

    keywords = list.compact.uniq.sort
    respond_to do |format|
      format.json {render :json => keywords}
    end
  end

  def update_temporal_extent
    datatable.update_temporal_extent
    datatable.save
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
            where('is_secondary is false and website_id = ?', website.id).all
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
