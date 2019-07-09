# frozen_string_literal: true

class DatasetFilesController < ApplicationController
  include FileSource
  def show
    dataset_file = DatasetFile.find(params[:id])
    file_from_s3(dataset_file.data)
  end
end
