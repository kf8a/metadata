class DatatablesController < ApplicationController
  
  #before_filter :is_restricted
   before_filter :login_required, :except => [:index, :show, :suggest] if ENV["RAILS_ENV"] == 'production'
  
  # GET /datatables
  # GET /datatables.xml
  def index

    # just use the lower case (ie the datatable themese)
    @themes = Theme.roots
    
    @default_value = 'Search for themes, core areas, keywords, contributors or words in the abstract'

    query =  {'keyword_list' => ''}
    query.merge!(params) unless params['commit'] == 'Clear'
            
    @keyword_list = query['keyword_list']
    @keyword_list = nil if @keyword_list.empty? || @keyword_list == @default_value
    
    if @keyword_list
      @datatables = Datatable.search @keyword_list
    else
      @datatables = Datatable.all
    end
    
    @studies = Study.find_all_with_datatables(@datatables, {:order => 'weight'})
       
    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @datatables.to_xml }
      format.rss {render :rss => @datatables}
    end
  end

  # GET /datatables/1
  # GET /datatables/1.xml
  # GET /datatables/1.csv
  def show  
    @datatable = Datatable.find(params[:id])
    @dataset = @datatable.dataset
    @roles = @dataset.roles
    
    @values = nil
    if @datatable.is_sql
      query =  @datatable.object
      #@data_count = ActiveRecord::Base.connection.execute("select count() from (#{@datatable.object}) as t1")
      
      @datatable.excerpt_limit = 50 if @datatable.excerpt_limit.nil?
      query = query + " limit #{@datatable.excerpt_limit}" 
      @values  = ActiveRecord::Base.connection.execute(query)
      #TDOD convert the array into a ruby object
    end

    unless trusted_ip?
      if @datatable.is_restricted  
        @values = nil
        restricted = true
      end
    end
        
    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @datatable.to_xml unless restricted}
      format.csv  { render :text => @datatable.to_csv unless restricted}
    end
  end

  # GET /datatables/new
  def new
    @datatable = Datatable.new
    @themes = Theme.find(:all, :order => 'name').collect {|x| [x.name, x.id]}
    @core_areas = CoreArea.find(:all, :order => 'name').collect {|x| [x.name, x.id]}
  end

  # GET /datatables/1;edit
  def edit
    @datatable = Datatable.find(params[:id])
    
    @core_areas = CoreArea.find(:all, :order => 'name').collect {|x| [x.name, x.id]}
  end

  # POST /datatables
  # POST /datatables.xml
  def create
    @datatable = Datatable.new(params[:datatable])

    respond_to do |format|
      if @datatable.save
        flash[:notice] = 'Datatable was successfully created.'
        format.html { redirect_to datatable_url(@datatable) }
        format.xml  { head :created, :location => datatable_url(@datatable) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @datatable.errors.to_xml }
      end
    end
  end

  # PUT /datatables/1
  # PUT /datatables/1.xml
  def update
    @datatable = Datatable.find(params[:id])

    respond_to do |format|
      if @datatable.update_attributes(params[:datatable])
        flash[:notice] = 'Datatable was successfully updated.'
        format.html { redirect_to datatable_url(@datatable) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
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
  
  def suggest
    term = params[:term]
    list = Tag.all.collect(&:name)
    list = list + Person.find_all_with_dataset.collect(&:full_name)
    list = list + Theme.all.collect(&:name)
    keywords = list.collect  {|x| x =~ Regexp.new(term+'.',true) ? x : nil }.compact.sort.uniq
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
  def set_crumbs
    crumb = Struct::Crumb.new
    @crumbs = []
    return unless params[:id]
    crumb.url = '/datatables/'
    crumb.name = 'Data Catalog: Datatables'
    @crumbs << crumb
    crumb = Struct::Crumb.new
    
    datatable  = Datatable.find(params[:id])

    if datatable.study
      study = datatable.study
      crumb.url = study_path(study)
      crumb.name = study.name
      @crumbs << crumb
    end
    crumb = Struct::Crumb.new
    
    crumb.url =  dataset_path(datatable.dataset)
    crumb.name = datatable.dataset.title
    @crumbs << crumb
  
  end
  
end
