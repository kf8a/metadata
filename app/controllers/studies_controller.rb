class StudiesController < ApplicationController
  
  before_filter :admin?, :except => [:index, :show]  if Rails.env == 'production'
  before_filter :get_study, :only => [:edit, :update]
  
  #GET /studies
  def index
    @study_roots = Study.roots
  end
  
   # GET /studies/1;edit
  def edit
  end
  
   # POST /studies/1
  def update
    respond_to do |format|
      if @study.update_attributes(params[:study])
        flash[:notice] = 'Study was successfully updated.'
        format.html { redirect_to datatables_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @study.errors.to_xml }
      end
    end
  end
  
  private
  
  def get_study
    @study = Study.find(params[:id])
  end
end
