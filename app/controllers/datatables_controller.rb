class DatatablesController < ApplicationController
  
  # GET /datatables
  # GET /datatables.xml
  def index

    @datatables = [] # Datatable.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @datatables.to_xml }
    end
  end

  # GET /datatables/1
  # GET /datatables/1.xml
  def show
    @datatable = Datatable.find(params[:id])
    @dataset = @datatable.dataset
    
    @values
    if @datatable.is_sql
      @values  = ActiveRecord::Base.connection.execute(@datatable.object)
    end

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @datatable.to_xml }
    end
  end

  # GET /datatables/new
  def new
    @datatable = Datatable.new
  end

  # GET /datatables/1;edit
  def edit
    @datatable = Datatable.find(params[:id])
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
