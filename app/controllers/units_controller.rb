# frozen_string_literal: true

# Display units. This is not used much
class UnitsController < ApplicationController
  before_action :require_login, except: %i[index show]
  before_action :admin?, except: %i[index show]
  before_action :unit, only: %i[edit update show]
  before_action :custom_unit?, only: %i[edit update]

  def index
    @units = Unit.not_in_eml
  end

  def edit; end

  def update
    flash[:notice] = 'Unit was succesfully updated' if @unit.update(params[:unit])
    respond_with @unit
  end

  def show; end

  private

  def unit
    @unit = Unit.find(params[:id])
  end

  def custom_unit?
    !@unit.in_eml
  end
end
