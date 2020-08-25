# frozen_string_literal: true

# handle the Studies page
class StudiesController < ApplicationController
  before_action :admin?, except: %i[index show]
  before_action :study, only: %i[edit update]

  # GET /studies
  def index
    @study_roots = Study.roots
  end

  # GET /studies/1;edit
  def edit; end

  # POST /studies/1
  def update
    respond_to do |format|
      if @study.update(study_params)
        flash[:notice] = 'Study was successfully updated.'
        format.html { redirect_to datatables_url }
        format.xml { head :ok }
      else
        format.html { render 'edit' }
        format.xml { render xml: @study.errors.to_xml }
      end
    end
  end

  private

  def study
    @study = Study.find(params[:id])
  end

  def study_params
    params.require(:study).permit(:name, :description, :weight, :synopsis, :url, :code)
  end
end
