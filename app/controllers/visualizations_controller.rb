# frozen_string_literal: true

# Serves the data behind a datatable's QC graphs. It is the datatable's rows, so it is refused to anyone
# who could not download the datatable's CSV.
class VisualizationsController < ApplicationController
  respond_to :json

  def show
    visualization = Visualization.find(params[:id])
    return head(:forbidden) unless visualization.viewable_by?(current_user)

    respond_with visualization.data
  end
end
