class DatatablesController < ApplicationController
  
  #before_filter :is_restricted
  
  # GET /datatables
  # GET /datatables.xml
  def index

    @themes = Theme.roots
    @studies = Study.all(:order => 'weight')
    @people = Person.find_all_with_dataset(:order => 'sur_name')
    
    query =  {'theme' => {'id' => nil}, 'person' => {'id' => nil}, 'study' => {'id' => nil}, 
      'keywords' => '', 'date' => {'syear' => '1988', 'eyear' => Date.today.year.to_s}}
    query.merge!(params)
    
    theme_id = query['theme']['id']
    person_id = query['person']['id']
    study_id = query['study']['id']
    keyword_list = query['keyword_list']
    date = query['date']
    
    if theme_id && !theme_id.empty?
      @theme = Theme.find(theme_id)
    end
    
    if person_id && !person_id.empty?
      @person = Person.find(person_id)
    end
    
    if study_id && !study_id.empty?
      @study = Study.find(study_id)
    end
    
    if keyword_list
      @keyword_list = keyword_list
    end
      
    @datatables = Datatable.find_by_params({:theme => {:id => theme_id}, :study => {:id => study_id},
        :person => {:id => person_id}, :keywords => keyword_list })
       
       #   :date => {:syear => date['syear'], :eyear => date['eyear']}
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
    
    @values = nil
    if @datatable.is_sql
      query =  @datatable.object
      #@data_count = ActiveRecord::Base.connection.execute("select count() from (#{@datatable.object}) as t1")
      
      @datatable.excerpt_limit = 50 if @datatable.excerpt_limit.nil?
      query = query + " limit #{@datatable.excerpt_limit}" 
      @values  = ActiveRecord::Base.connection.execute(query)
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
  
  private
  def set_crumbs
    crumb = Struct::Crumb.new
    @crumbs = []
    return unless params[:id]
    crumb.url = '/datasets/'
    crumb.name = 'Data Catalog: Datasets'
    @crumbs << crumb
    crumb = Struct::Crumb.new
    
    datatable  = Datatable.find(params[:id])
    crumb.url =  dataset_path(datatable.dataset)
    crumb.name = datatable.dataset.title
    @crumbs << crumb
  
  end
  
end
