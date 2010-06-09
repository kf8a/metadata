class GlbrcController < ApplicationController

  def index
    # just use the lower case (ie the datatable themese)
    @themes = Theme.roots

    @default_value = 'Search for core areas, keywords or people'

    query =  {'keyword_list' => ''}
    query.merge!(params) unless params['commit'] == 'Clear'

    @keyword_list = query['keyword_list']
    @keyword_list = nil if @keyword_list.empty? || @keyword_list == @default_value

    if @keyword_list
      @datatables = Datatable.search @keyword_list, :with => {:website_id => Website.find_by_name('GLBRC').id}
    else
      @datatables = Datatable.find(:all, :conditions => ['is_secondary is false and website_id = ?',  Website.find_by_name('GLBRC')])
    end

    @studies = Study.find_all_roots_with_datatables(@datatables, {:order => 'weight'})
    
    @protocols = @datatables.collect do |datatable|
      datatable.dataset.protocols
    end.flatten.uniq
    

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
      format.csv  { render :text => @datatable.to_csv_with_metadata unless restricted}
      format.climdb { render :text => @datatable.to_climdb unless restricted }
    end
  end
  
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
      format.csv  { render :text => @datatable.to_csv_with_metadata unless restricted}
      format.climdb { render :text => @datatable.to_climdb unless restricted }
    end
  end

  def suggest
    term = params[:term]
    #list = Tag.all.collect {|x| x.name.downcase}
    # list = list + Person.find_all_with_dataset.collect {|x| x.sur_name.downcase}
    list = Theme.all.collect {|x| x.name.downcase}

    keywords = list.compact.uniq.sort
    respond_to do |format|
      format.json {render :json => keywords}
    end
  end

  private
    
  def set_title
    @title  = 'GLBRC Sustainability'
  end

end
