class ProtocolsController < ApplicationController
  
  before_filter :set_title
  # GET /protocols
  # GET /protocols.xml
  def index
    @themes = Theme.find(:all)
    @protocols = Protocol.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @protocols.to_xml }
    end
  end

  # GET /protocols/1
  # GET /protocols/1.xml
  def show
    @protocol = Protocol.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @protocol.to_xml }
    end
  end

  # GET /protocols/new
  def new
    @protocol = Protocol.new
    @people = Person.find(:all, :order => :sur_name)
  end

  # GET /protocols/1;edit
  def edit
    @protocol = Protocol.find(params[:id])
    @people = Person.find(:all, :order => :sur_name)
    
  end

  # POST /protocols
  # POST /protocols.xml
  def create
    @protocol = Protocol.new(params[:protocol])
    @people = Person.find(:all, :order => :sur_name)
    
    respond_to do |format|
      if @protocol.save
        flash[:notice] = 'Protocol was successfully created.'
        format.html { redirect_to protocol_url(@protocol) }
        format.xml  { head :created, :location => protocol_url(@protocol) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @protocol.errors.to_xml }
      end
    end
  end

  # PUT /protocols/1
  # PUT /protocols/1.xml
  def update
    @protocol = Protocol.find(params[:id])

    respond_to do |format|
      if @protocol.update_attributes(params[:protocol])
        flash[:notice] = 'Protocol was successfully updated.'
        format.html { redirect_to protocol_url(@protocol) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @protocol.errors.to_xml }
      end
    end
  end

  # DELETE /protocols/1
  # DELETE /protocols/1.xml
  def destroy
    @protocol = Protocol.find(params[:id])
    @protocol.destroy

    respond_to do |format|
      format.html { redirect_to protocols_url }
      format.xml  { head :ok }
    end
  end
  
  private
  def set_title
    @title = 'Protocols'
  end
  def set_crumbs
    crumb = Struct::Crumb.new
    @crumbs = []
    return unless params[:id]
    crumb.url = protocols_path
    crumb.name = 'Data Catalog: Protocols'
    @crumbs << crumb
  end
end
