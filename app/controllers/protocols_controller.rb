class ProtocolsController < ApplicationController

  before_filter :admin?, :except => [:index, :show]  if Rails.env != 'development'
  before_filter :get_protocol, :only => [:edit, :update, :destroy]
    
  cache_sweeper :protocol_sweeper
  
  # GET /protocols
  # GET /protocols.xml
  def index
    store_location
    @website = website

    @protocols = website.protocols.find(:all, :order => 'title', :conditions => ['active = true'])
    @protocol_themes = website.protocols.all_tag_counts(:on=>:themes).order('name')
    @experiment_protocols = website.protocols.tagged_with(:experiments).where(:active => true).order('title')

    @untagged_protocols = website.protocols.where(:active=>true).all.collect {|e| e if e.theme_list.blank? }.compact

    respond_with @protocols
  end

  # GET /protocols/1
  # GET /protocols/1.xml
  def show
    store_location
    @protocol = website.protocols.first(:conditions => ['id = ?', params[:id]])

    if @protocol
      respond_with @protocol
    else
      respond_to do |format|
        format.html { redirect_to protocols_url}
        format.xml  { head :not_found}
      end
    end
  end

  # GET /protocols/new
  def new
    @protocol = Protocol.new
    @datasets = Dataset.find(:all).map {|dataset| [dataset.dataset, dataset.id]}
    get_all_websites
  end

  # GET /protocols/1;edit
  def edit
    @datasets = Dataset.find(:all).map {|dataset| [dataset.dataset, dataset.id]}
    get_all_websites
  end

  # POST /protocols
  # POST /protocols.xml
  def create
    @protocol = Protocol.new(params[:protocol])

    if @protocol.save
      flash[:notice] = 'Protocol was successfully created.'
    end

    respond_with @protocol
  end

  # PUT /protocols/1
  # PUT /protocols/1.xml
  def update
    params[:protocol].merge!({:updated_by => current_user})
    get_all_websites
    if params[:new_version]
      old_protocol = Protocol.find(params[:id])
      @protocol = Protocol.new(params[:protocol])
      @protocol.deprecate!(old_protocol)
    end
    if @protocol.update_attributes(params[:protocol])
      flash[:notice] = 'Protocol was successfully updated.'
    end

    respond_with @protocol
  end

  # DELETE /protocols/1
  # DELETE /protocols/1.xml
  def destroy
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
  
  def get_all_websites
    @websites = Website.all
  end
  
  def find_website
 
  end
  
  def get_protocol
    @protocol = Protocol.find(params[:id])
  end
end
