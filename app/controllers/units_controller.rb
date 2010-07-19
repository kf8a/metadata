class UnitsController < ApplicationController
  
  before_filter :is_custom_unit, :except => ['show','index']
  before_filter :admin?, :except => [:index, :show]  if ENV["RAILS_ENV"] == 'production'
  
  
  def index
    @units = Unit.find(:all, :conditions => ['in_eml is false'])
  end
  
  
  def edit
    @unit = Unit.find(params[:id])
  end
  
  def update
    @unit = Unit.find(params[:id])
    
    respond_to do |format|
      if @unit.update_attributes(params[:unit])
        flash[:notice] = 'Unit was succesfully updated'
        format.html {redirect_to unit_url(@unit)}
        format.xml {head :ok}
      else
        format.html {render :action => 'edit'}
        format.xml { render :xml => @unit.errors.to_xml }
      end
    end
  end
  
  def show
    @unit = Unit.find(params[:id])
  end
  
private
  def is_custom_unit
    unit = Unit.find(params[:id])
    return !unit.in_eml
  end
end
