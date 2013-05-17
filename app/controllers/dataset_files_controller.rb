class DatasetFilesController < ApplicationController
  def show 
    dataset_file = DatasetFile.find(params[:id])
    send_file dataset_file.data.path(params[:style]), :filename => dataset_file.data_file_name
  end
end
