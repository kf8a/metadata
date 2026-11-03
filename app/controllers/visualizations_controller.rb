# frozen_string_literal: true

# Serves the data behind the d3 QC graphs on a datatable's QC page. It is the datatable's rows, so it is
# refused to anyone who could not download the datatable's CSV.
class VisualizationsController < ApplicationController
  respond_to :json

  def show
    visualization = Visualization.find(params.expect(:id))
    return head(:forbidden) unless visualization.viewable_by?(current_user)

    respond_with visualization.data
  end
end
