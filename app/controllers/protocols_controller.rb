class ProtocolsController < ApplicationController

  layout :site_layout
  before_filter :admin?, :except => [:index, :show]  if Rails.env != 'development'
  before_filter :get_protocol, :only => [:edit, :update, :destroy]
    
  cache_sweeper :protocol_sweeper
  
  # GET /protocols
  # GET /protocols.xml
  def index
    store_location
    @themes = Theme.roots
    website =  Website.find_by_name(@subdomain_request)
    @protocols = website.protocols.find(:all, :order => 'title', :conditions => ['active = true'])

    respond_to do |format|
      format.html { render_subdomain }
      format.xml  { render :xml => @protocols.to_xml }
    end
  end

  # GET /protocols/1
  # GET /protocols/1.xml
  def show
    store_location
    website =  Website.find_by_name(@subdomain_request)
    @protocol = website.protocols.first(:conditions => ['id = ?', params[:id]])

    respond_to do |format|
      if @protocol
        format.html { render_subdomain }
        format.xml  { render :xml => @protocol.to_xml }
      else
        format.html { redirect_to protocols_url}
        format.xml  { head :not_found}
      end
    end
  end

  # GET /protocols/new
  def new
    @protocol = Protocol.new
    @people = Person.by_sur_name
    @datasets = Dataset.find(:all).map {|x| [x.dataset, x.id]}
    get_all_websites
  end

  # GET /protocols/1;edit
  def edit
    @people = Person.by_sur_name
    @datasets = Dataset.find(:all).map {|x| [x.dataset, x.id]}
    get_all_websites
  end

  # POST /protocols
  # POST /protocols.xml
  def create
    @protocol = Protocol.new(params[:protocol])
    @people = Person.by_sur_name
    
    respond_to do |format|
      if @protocol.save
        
        flash[:notice] = 'Protocol was successfully created.'
        format.html { redirect_to protocol_url(@protocol) }
        format.xml  { head :created, :location => protocol_url(@protocol) }
      else
        format.html { render_subdomain "new" }
        format.xml  { render :xml => @protocol.errors.to_xml }
      end
    end
  end

  # PUT /protocols/1
  # PUT /protocols/1.xml
  def update
    get_all_websites
    
    respond_to do |format|
      if params[:new_version]
        old_protocol = Protocol.find(params[:id])
        @protocol = Protocol.new(params[:protocol])
        @protocol.deprecate(old_protocol)
      end
      if @protocol.update_attributes(params[:protocol])
        flash[:notice] = 'Protocol was successfully updated.'
        format.html { redirect_to protocol_url(@protocol) }
        format.xml  { head :ok }
      else
        format.html { render_subdomain "edit" }
        format.xml  { render :xml => @protocol.errors.to_xml }
      end
    end
  end

  # DELETE /protocols/1
  # DELETE /protocols/1.xml
  def destroy
    @protocol.destroy

    expire_action :action => :index
    
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
  
  def get_all_websites
    @websites = Website.all
  end
  
  def find_website
 
  end
  
  def get_protocol
    @protocol = Protocol.find(params[:id])
  end
end
