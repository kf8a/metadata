class DatasetFilesController < ApplicationController
  def show 
    dataset_file = DatasetFile.find(params[:id])
    path = dataset_file.data.path(params[:style])
    if Rails.env.production?
      redirect_to(dataset_file.data.s3_object(params[:style]).url_for(:read ,:secure => true, :expires_in => 10.seconds).to_s)
    else
      send_file  path, :type => 'application/pdf', :disposition => 'inline'
    end
  end
end
