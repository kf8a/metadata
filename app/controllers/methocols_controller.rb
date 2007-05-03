class MethocolsController < ApplicationController
  # GET /methocols
  # GET /methocols.xml
  def index
    @themes = Theme.find(:all)
    @methocols = Methocol.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @methocols.to_xml }
    end
  end

  # GET /methocols/1
  # GET /methocols/1.xml
  def show
    @methocol = Methocol.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @methocol.to_xml }
    end
  end

  # GET /methocols/new
  def new
    @methocol = Methocol.new
  end

  # GET /methocols/1;edit
  def edit
    @methocol = Methocol.find(params[:id])
  end

  # POST /methocols
  # POST /methocols.xml
  def create
    @methocol = Methocol.new(params[:methocol])

    respond_to do |format|
      if @methocol.save
        flash[:notice] = 'Methocol was successfully created.'
        format.html { redirect_to methocol_url(@methocol) }
        format.xml  { head :created, :location => methocol_url(@methocol) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @methocol.errors.to_xml }
      end
    end
  end

  # PUT /methocols/1
  # PUT /methocols/1.xml
  def update
    @methocol = Methocol.find(params[:id])

    respond_to do |format|
      if @methocol.update_attributes(params[:methocol])
        flash[:notice] = 'Methocol was successfully updated.'
        format.html { redirect_to methocol_url(@methocol) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @methocol.errors.to_xml }
      end
    end
  end

  # DELETE /methocols/1
  # DELETE /methocols/1.xml
  def destroy
    @methocol = Methocol.find(params[:id])
    @methocol.destroy

    respond_to do |format|
      format.html { redirect_to methocols_url }
      format.xml  { head :ok }
    end
  end
end
