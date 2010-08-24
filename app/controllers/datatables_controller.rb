class DatatablesController < ApplicationController
  
  layout :site_layout

  before_filter :admin?, :except => [:index, :show, :suggest, :search] unless ENV["RAILS_ENV"] == 'development'
  
  #caches_action :show, :if => Proc.new { |c| c.request.format.csv? } # cache if it is a csv request
  
  # GET /datatables
  # GET /datatables.xml
  def index
    retrieve_datatables('keyword_list' =>'')
    @default_value = 'Search for core areas, keywords or people'
    subdomain_request = request_subdomain(params[:requested_subdomain])
    page = template_choose(subdomain_request, "datatables", "index")
        
    respond_to do |format|
      format.html {render page}
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
      subdomain_request = request_subdomain(params[:requested_subdomain])
      page = template_choose(subdomain_request, "datatables", "search")
      respond_to do |format|
        format.html {render page}
      end
    end
  end

  # GET /datatables/1
  # GET /datatables/1.xml
  # GET /datatables/1.csv
  def show  
    @datatable = Datatable.find(params[:id])
    @dataset = @datatable.dataset

    @values = nil
    if (!trusted_ip? && @datatable.is_restricted)
      restricted = true
    else
      @values = @datatable.perform_query if @datatable.is_sql
    end

    subdomain_request = request_subdomain(params[:requested_subdomain])
    @website_name = @dataset.website.try(:name)
    if @website_name and @website_name != subdomain_request
      redirect_to datatables_url
      return false
    end
    page = template_choose(subdomain_request, "datatables", "show")
    respond_to do |format|
      format.html   { render page}
      format.xml    { render :xml => @datatable.to_xml}
      if @datatable.restricted?
        if signed_in? and current_user.allowed?(@datatable)
          format.csv    { render :text => @datatable.to_csv_with_metadata }
        else
          format.csv { redirect_to datatable_url(@datatable) }
        end
      else
        format.csv    { render :text => @datatable.to_csv_with_metadata }
      end
      format.climdb { render :text => @datatable.to_climdb } unless restricted
      format.climdb { redirect_to datatable_url(@datatable) } if restricted
    end
  end

  # GET /datatables/new
  def new
    @datatable = Datatable.new
    @themes = Theme.all(:order => 'name').collect {|x| [x.name, x.id]}
    @core_areas = CoreArea.all(:order => 'name').collect {|x| [x.name, x.id]}
  end

  # GET /datatables/1;edit
  def edit
    @datatable = Datatable.find(params[:id])

    @core_areas = CoreArea.all(:order => 'name').collect {|x| [x.name, x.id]}
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
    @core_areas = CoreArea.all(:order => 'name').collect {|x| [x.name, x.id]}

    subdomain_request = request_subdomain(params[:requested_subdomain])
    respond_to do |format|
      if @datatable.save
        flash[:notice] = 'Datatable was successfully created.'
        format.html { redirect_to datatable_url(@datatable) }
        format.xml  { head :created, :location => datatable_url(@datatable) }
      else
        page = template_choose(subdomain_request, "datatables", "new")
        format.html { render page }
        format.xml  { render :xml => @datatable.errors.to_xml }
      end
    end
  end

  # PUT /datatables/1
  # PUT /datatables/1.xml
  def update
    subdomain_request = request_subdomain(params[:requested_subdomain])
    @datatable = Datatable.find(params[:id])

    respond_to do |format|
      if @datatable.update_attributes(params[:datatable])
        flash[:notice] = 'Datatable was successfully updated.'
        format.html { redirect_to datatable_url(@datatable) }
        format.xml  { head :ok }
      else
        @core_areas = CoreArea.find(:all, :order => 'name').collect {|x| [x.name, x.id]}
        page = template_choose(subdomain_request, "datatables", "edit")
        format.html { render page }
        format.xml  { render :xml => @datatable.errors.to_xml }
      end
    end
  end

  # DELETE /datatables/1
  # DELETE /datatables/1.xml
  def destroy
    @datatable = Datatable.find(params[:id])
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
    @datatable = Datatable.find(params[:id])
    @datatable.update_temporal_extent
    @datatable.save
    respond_to do |format|
      format.js {render :nothing => true}
    end
  end

  private

  def set_title
    if request_subdomain(params[:requested_subdomain]) == "lter"
      @title  = 'LTER Data Catalog'
    else
      @title = 'GLBRC Data Catalog'
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
    @themes = Theme.roots

    @keyword_list = query['keyword_list']
    @keyword_list = nil if @keyword_list.empty? || @keyword_list == @default_value

    if @keyword_list
      @datatables = Datatable.search @keyword_list, :tag => {:website => current_subdomain}
    else
      @datatables = Datatable.all( 
          :joins=> 'left join datasets on datasets.id = datatables.dataset_id', 
          :conditions => ['is_secondary is false and website_id = ?',
              Website.find_by_name(current_subdomain)])
    end

    @studies = Study.find_all_roots_with_datatables(@datatables, {:order => 'weight'})

  end
  
end
