# frozen_string_literal: true

# show visualizations for protovis or other javascript graphs
class VisualizationsController < ApplicationController
  respond_to :json

  def show
    visualization = Visualization.find(params[:id])
    respond_with visualization.data
  end
end
