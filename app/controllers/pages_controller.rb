class PagesController < ApplicationController
 
  before_filter :admin?, :except => [:show] unless Rails.env == 'development'
  helper_method :page

  def index
    return head :bad_request
  end

  def show
    @page = page
    @title = @page.title
  end

  def new
    @page = Page.new
    @page.page_images << PageImage.new
  end

  def create
    @page = Page.new(page_params)
    if @page.save
      flash[:notice] = 'Page was successfully created.'
    end

    respond_with @page
  end

  def edit
    @page = page
  end

  def update
    if page.update_attributes(page_params)
      flash[:notice] = 'Page was successfully updated.'
    end

    respond_with page
  end

  def destroy 
    page.destroy
    redirect_to :action => 'index'
  end

  private

  def page
    Page.find(params[:id])
  end

  def page_params
    params.require(:page).permit(:title, :body, :url)
  end

end
