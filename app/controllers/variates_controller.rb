# frozen_string_literal: true%i

# Display variates, this is not used much and might
# be deleted
class VariatesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :admin?, except: %i[index show]
  before_action :variate, only: %i[show edit update destroy]

  # GET /variates
  # GET /variates.xml
  def index
    @variates = Variate.all

    respond_to do |format|
      format.html
      format.xml { render xml: @variates.to_xml }
    end
  end

  # GET /variates/1
  # GET /variates/1.xml
  def show
    respond_to do |format|
      format.html
      format.xml { render xml: @variate.to_xml }
    end
  end

  # GET /variates/new
  def new
    @variate = Variate.new
    respond_to do |format|
      format.html
    end
  end

  # GET /variates/1;edit
  def edit
  end

  # POST /variates
  # POST /variates.xml
  def create
    @variate = Variate.new(params[:variate])

    if @variate.save
      flash[:notice] = 'Variate was successfully created.'
    end
    respond_with @variate
  end

  # PUT /variates/1
  # PUT /variates/1.xml
  def update
    if @variate.update_attributes(params[:variate])
      flash[:notice] = 'Variate was successfully updated.'
    end
    respond_with @variate
  end

  # DELETE /variates/1
  # DELETE /variates/1.xml
  def destroy
    @variate.destroy

    respond_to do |format|
      format.html { redirect_to variates_url }
      format.xml  { head :ok }
    end
  end

  private

  def variate
    @variate = Variate.find(params[:id])
  end
end
