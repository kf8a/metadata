class PagesController < ApplicationController
  
  layout :site_layout
  
  before_filter :admin?, :except => [:show] unless Rails.env == 'development'
  before_filter :get_page, :only => [:show, :edit, :update, :destroy]
  
  def index
    return head :bad_request
  end
  
  def show
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
  end
  
  def update
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
    @page.destroy
    redirect_to :action => 'index'
  end
  
  private
  
  def get_page
    @page = Page.find(params[:id])
  end
 
end
