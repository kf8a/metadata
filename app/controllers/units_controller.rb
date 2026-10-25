# frozen_string_literal: true

# Display units. This is not used much
class UnitsController < ApplicationController
  before_action :admin?, except: %i[index show]
  before_action :unit, only: %i[edit update show]
  before_action :require_custom_unit, only: %i[edit update]

  def index
    @units = Unit.not_in_eml
  end

  def show; end
  def edit; end

  def update
    flash[:notice] = 'Unit was succesfully updated' if @unit.update(unit_params)
    respond_with @unit
  end

  private

  def unit
    @unit = Unit.find(params[:id])
  end

  def unit_params
    params.require(:unit).permit(:name, :description, :definition)
  end

  # Units defined by EML are standard and can't be changed here
  def require_custom_unit
    return unless @unit.in_eml

    flash[:notice] = 'EML standard units cannot be edited'
    redirect_to unit_url(@unit)
  end
end
