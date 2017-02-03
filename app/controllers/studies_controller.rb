# handle the Studies page
class StudiesController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :admin?, except: [:index, :show]
  before_action :study, only: [:edit, :update]

  # GET /studies
  def index
    @study_roots = Study.roots
  end

  def move_to
    study = Study.find(params[:parent_id])
    child = Study.find(params[:id])
    child.move_to_child_of(study) unless child == study
    render partial: 'study', locals: { study: study }
  end

  def move_before
    study = Study.find(params[:parent_id])
    child = Study.find(params[:id])
    father = study.parent
    child.move_to_left_of(study) unless child == study
    if study.root?
      render partial: 'study_list', locals: { study_roots: Study.roots }
    else
      render partial: 'study', locals: { study: father }
    end
  end

  # GET /studies/1;edit
  def edit
  end

  # POST /studies/1
  def update
    respond_to do |format|
      if @study.update_attributes(study_params)
        flash[:notice] = 'Study was successfully updated.'
        format.html { redirect_to datatables_url }
        format.xml  { head :ok }
      else
        format.html { render 'edit' }
        format.xml  { render xml: @study.errors.to_xml }
      end
    end
  end

  private

  def study
    @study = Study.find(params[:id])
  end

  def study_params
    params.require(:study).permit(:name, :description, :weight,
                                  :synopsis, :url, :code)
  end
end
