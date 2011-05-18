class PagesController < ApplicationController
  
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
    if @page.save
      flash[:notice] = 'Page was successfully created.'
    end

    respond_with @page
  end
  
  def edit
  end
  
  def update
    if @page.update_attributes(params[:page])
      flash[:notice] = 'Page was successfully updated.'
    end

    respond_with @page
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
