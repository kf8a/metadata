# Display units. This is not used much
class UnitsController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :admin?, except: [:index, :show]
  before_action :unit, only: [:edit, :update, :show]
  before_action :custom_unit?, only: [:edit, :update]

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

  def unit
    @unit = Unit.find(params[:id])
  end

  def custom_unit?
    !@unit.in_eml
  end
end
