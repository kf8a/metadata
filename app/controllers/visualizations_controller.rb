# frozen_string_literal: true

# Serves the data behind the d3 QC graphs on a datatable's QC page
class VisualizationsController < ApplicationController
  respond_to :json

  def show
    visualization = Visualization.find(params[:id])
    respond_with visualization.data
  end
end
