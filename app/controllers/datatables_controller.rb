class DatatablesController < ApplicationController

  layout :site_layout

  before_filter :admin?, :except => [:index, :show, :suggest, :search, :events] unless Rails.env == 'development'
  before_filter :get_datatable, :only => [:show, :edit, :update, :destroy, :update_temporal_extent]
  
  cache_sweeper :datatable_sweeper
  caches_action :show, :if => Proc.new { |c| c.request.format.csv? } # cache if it is a csv request
  
  # GET /datatables
  # GET /datatables.xml
  def index
    retrieve_datatables('keyword_list' =>'')
    
    respond_to do |format|
      format.html {render_subdomain}
      format.xml  { render :xml => @datatables.to_xml }
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
      respond_to do |format|
        format.html {render_subdomain}
      end
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
    accessible_by_ip = trusted_ip? || !@datatable.is_restricted
    csv_ok = accessible_by_ip && @datatable.can_be_downloaded_by?(current_user)
    climdb_ok = accessible_by_ip
    
    @website = Website.find_by_name(@subdomain_request)
    @trusted = trusted_ip?

    if @datatable.dataset.valid_request?(@subdomain_request)
      respond_to do |format|
        format.html   { render_subdomain }
        format.xml    { render :xml => @datatable.to_xml}
        format.ods do
          if csv_ok
            render :text => @datatable.to_ods
          else
            redirect_to datatable_url(@datatable)
          end
        end
        format.csv do
          if csv_ok
            render :text => @datatable.to_csv_with_metadata
          else
            redirect_to datatable_url(@datatable)
          end
        end
        format.climdb do
          if climdb_ok
            render :text => @datatable.to_climdb
          else
            redirect_to datatable_url(@datatable)
          end
        end
      end
    else
      redirect_to datatables_url
    end
  end

  # GET /datatables/new
  def new
    @datatable = Datatable.new
    @themes = Theme.by_name.collect {|x| [x.name, x.id]}
    @core_areas = CoreArea.by_name.collect {|x| [x.name, x.id]}
    @studies = Study.all.collect{|x| [x.name, x.id]}
    @people = Person.all
    @units = Unit.all
  end

  # GET /datatables/1;edit
  def edit
    @core_areas = CoreArea.by_name.collect {|x| [x.name, x.id]}
    @studies = Study.all.collect{|x| [x.name, x.id]}
    @people = Person.all
    @units = Unit.all
  end
  
  def delete_csv_cache
    @id = params[:id]
    expire_action :action => "show", :id => @id, :format => "csv"
    flash[:notice] = 'Datatable cache was successfully deleted.'
    redirect_to :action => "edit", :id => @id
  end

  # POST /datatables
  # POST /datatables.xml
  def create
    @datatable = Datatable.new(params[:datatable])
    @core_areas = CoreArea.by_name.collect {|x| [x.name, x.id]}
    @studies = Study.all.collect{|x| [x.name, x.id]}
    @people = Person.all
    @units = Unit.all
    
    respond_to do |format|
      if @datatable.save
        flash[:notice] = 'Datatable was successfully created.'
        format.html { redirect_to datatable_url(@datatable) }
        format.xml  { head :created, :location => datatable_url(@datatable) }
      else
        format.html { render_subdomain "new" }
        format.xml  { render :xml => @datatable.errors.to_xml }
      end
    end
  end

  # PUT /datatables/1
  # PUT /datatables/1.xml
  def update
    @core_areas = CoreArea.by_name.collect {|x| [x.name, x.id]}
    @studies = Study.all.collect{|x| [x.name, x.id]}
    @people = Person.all
    @units = Unit.all
    
    respond_to do |format|
      if @datatable.update_attributes(params[:datatable])
        flash[:notice] = 'Datatable was successfully updated.'
        format.html { redirect_to datatable_url(@datatable) }
        format.xml  { head :ok }
      else

        format.html { render_subdomain "edit" }
        format.xml  { render :xml => @datatable.errors.to_xml }
      end
    end
  end

  # DELETE /datatables/1
  # DELETE /datatables/1.xml
  def destroy
    @datatable.destroy

    respond_to do |format|
      format.html { redirect_to datatables_url }
      format.xml  { head :ok }
    end
  end

  #TODO only return the ones for the right website.
  def suggest
    term = params[:term]
    #  list = Datatable.tags.all.collect {|x| x.name.downcase}
    list = Person.find_all_with_dataset.collect {|x| x.sur_name.downcase}
    list = list + Theme.all.collect {|x| x.name.downcase}
    list = list + CoreArea.all.collect {|x| x.name.downcase}

    keywords = list.compact.uniq.sort
    respond_to do |format|
      format.json {render :json => keywords}
    end
  end

  def update_temporal_extent
    @datatable.update_temporal_extent
    @datatable.save
    respond_to do |format|
      format.js {render :nothing => true}
    end
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

  def get_datatable
    @datatable = Datatable.find(params[:id])
  end
  
  def retrieve_datatables(query)
    @default_value = 'Search for core areas, keywords or people'
    @themes = Theme.roots

    @keyword_list = query['keyword_list']
    @keyword_list = nil if @keyword_list.empty? || @keyword_list == @default_value

    website = Website.find_by_name(@subdomain_request)
    website_id = (website.try(:id) or 1)
    if @keyword_list
      @datatables = Datatable.search @keyword_list, :with => {:website => website_id}
    else
      @datatables = Datatable.all( 
          :joins=> 'left join datasets on datasets.id = datatables.dataset_id', 
          :conditions => ['is_secondary is false and website_id = ?',
              Website.find_by_name(@subdomain_request)])
    end

    @studies = Study.find_all_roots_with_datatables(@datatables)

  end
  
end
