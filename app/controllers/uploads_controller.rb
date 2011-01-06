class UploadsController < ApplicationController

  layout :site_layout
  before_filter :can_upload?, :except => [:index, :show]  unless Rails.env == 'development'

  def index
    @uploads = Upload.all
  end
  
  def new
    @upload = Upload.new
  end
  
  def create
    @upload = Upload.new(params[:upload])

    respond_to do |format|
      if @upload.save
        flash[:notice] = 'Study was uploaded!'
        format.html { redirect_to upload_url(@upload) }
        format.xml  { head :created, :location => upload_url(@upload) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @upload.errors.to_xml }
      end
    end
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
  
end
