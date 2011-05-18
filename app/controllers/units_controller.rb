class UnitsController < ApplicationController
  
  before_filter :admin?, :except => [:index, :show]  if Rails.env == 'production'
  before_filter :get_unit, :only => [:edit, :update, :show]
  before_filter :is_custom_unit, :only => ['edit','update']
  

  def index
    @units = Unit.not_in_eml
  end
  
  def edit
  end
  
  def update
    if @unit.update_attributes(params[:unit])
      flash[:notice] = 'Unit was succesfully updated'
    end
    respond_with @unit
  end
  
  def show
  end
  
private
  def get_unit
    @unit = Unit.find(params[:id])
  end

  def is_custom_unit
    return !@unit.in_eml
  end
end
