class VisualizationsController < ApplicationController
  respond_to :json

  def show
    visualization = Visualization.find(params[:id])
    respond_with visualization.data
  end
end
