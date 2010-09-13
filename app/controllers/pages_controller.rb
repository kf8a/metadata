class PagesController < ApplicationController
  
  layout :site_layout
  
  before_filter :admin?, :except => [:show] unless ENV["RAILS_ENV"] == 'development'
  
  def index
    return head :bad_request
  end
  
  def show
    @page = Page.find(params[:id])
    @title = @page.title
  end
  
  def new
    @page = Page.new
    @page.page_images << PageImage.new
  end
  
  def create
    @page = Page.new(params[:page])

    respond_to do |format|
      if @page.save
        flash[:notice] = 'Page was successfully created.'
        format.html { redirect_to page_url(@page) }
        format.xml  { head :created, :location => datatable_url(@page) }
      else
        format.html { render_subdomain "new" }
        format.xml  { render :xml => @page.errors.to_xml }
      end
    end
  end
  
  def edit
    @page = Page.find(params[:id])
  end
  
  def update
    @page = Page.find(params[:id])

    respond_to do |format|
      if @page.update_attributes(params[:page])
        flash[:notice] = 'Page was successfully updated.'
        format.html { redirect_to page_url(@page) }
        format.xml  { head :ok }
      else
        format.html { render_subdomain "edit" }
        format.xml  { render :xml => @page.errors.to_xml }
      end
    end
  end
  
  def destroy 
    @page = Page.find(params[:id])
    @page.destroy
  end
 
end
