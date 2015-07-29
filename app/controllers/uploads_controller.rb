class UploadsController < ApplicationController

  before_filter :can_upload?, :except => [:index, :show]  unless Rails.env == 'development'

  def index
    @uploads = Upload.all
  end

  def new
    @upload = Upload.new
  end

  def create
    @upload = Upload.new(uploads_params)
    if @upload.save
      flash[:notice] = 'Study was uploaded!'
    end
    respond_with @upload
  end

  def show  
    @upload = Upload.find(params[:id])

    respond_to do |format|
      format.html #show.html.erb
    end
  end

  private

  def can_upload?
    current_user.try(:role) == 'admin' || current_user.try(:role) == 'uploader'
  end

  def set_title
    @title = "GLBRC Data Upload"
  end

  def uploads_params
    params.require(:upload).permit(:title, :abstract, :owners, :abstract, :file)
  end
end
