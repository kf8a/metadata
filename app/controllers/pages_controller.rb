# Controller for basic html pages. Used on the GLBRC site
class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:show]
  before_action :admin?, except: [:show]
  helper_method :page

  def index
    head :bad_request
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
    flash[:notice] = 'Page was successfully created.' if @page.save

    respond_with @page
  end

  def edit
    @page = page
  end

  def update
    flash[:notice] = 'Page was successfully updated.' if page.update(page_params)

    respond_with page
  end

  def destroy
    page.destroy
    redirect_to action: 'index'
  end

  private

  def page
    Page.find(params[:id].to_i)
  end

  def page_params
    params.require(:page).permit(:title, :body, :url)
  end
end
