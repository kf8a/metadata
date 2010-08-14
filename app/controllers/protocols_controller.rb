class ProtocolsController < ApplicationController
  
  layout :site_layout
  before_filter :admin?, :except => [:index, :show]  if ENV["RAILS_ENV"] == 'production'
  
  #caches_action :index
  
  # GET /protocols
  # GET /protocols.xml
  def index
    @themes = Theme.roots
  
    subdomain_request = request_subdomain(params[:requested_subdomain])
    website =  Website.find_by_name(subdomain_request)
    page = template_choose(subdomain_request, controller_name, action_name)
  
    @protocols = website.protocols.all

    respond_to do |format|
      format.html {render page}
      format.xml  { render :xml => @protocols.to_xml }
    end
  end

  # GET /protocols/1
  # GET /protocols/1.xml
  def show
    subdomain_request = request_subdomain(params[:requested_subdomain])
    website =  Website.find_by_name(subdomain_request)
    page = template_choose(subdomain_request, controller_name, action_name)
    
    @protocol = website.protocols.first(:conditions => ['id = ?', params[:id]])

     
    respond_to do |format|
      if @protocol
        format.html # show.rhtml
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
    @people = Person.find(:all, :order => :sur_name)
    get_all_websites
  end

  # GET /protocols/1;edit
  def edit
    @protocol = Protocol.find(params[:id])
    @people = Person.find(:all, :order => :sur_name)
    get_all_websites
  end

  # POST /protocols
  # POST /protocols.xml
  def create
    @protocol = Protocol.new(params[:protocol])
    @people = Person.find(:all, :order => :sur_name)
    
    respond_to do |format|
      if @protocol.save
        expire_action :action => :index
        
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
    get_all_websites
  
    respond_to do |format|
      if @protocol.update_attributes(params[:protocol])
        expire_action :action => :index
        
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
  
end
