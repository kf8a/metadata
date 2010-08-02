class StudiesController < ApplicationController
  
  before_filter :admin?, :except => [:index, :show]  if ENV["RAILS_ENV"] == 'production'
  
  #GET /studies
  def index
    @study_roots = Study.roots
  end
  
   # GET /studies/1;edit
  def edit
    @study = Study.find(params[:id])
  end
  
   # POST /studies/1
  def update
    @study = Study.find(params[:id])

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
end
