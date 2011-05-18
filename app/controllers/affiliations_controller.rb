class AffiliationsController < ApplicationController

  before_filter :admin?, :except => [:index, :show] unless Rails.env == 'development'
  before_filter :get_affiliation, :only => [:show, :edit, :update, :destroy]

  def index
    @affiliations = Affiliation.all
  end
  
  def show
  end
  
  def edit
  end

  def update
    if @affiliation.update_attributes(params[:affiliation])
      flash[:notice] = 'Affiliation was successfully updated.'
    end
    respond_with @affiliation
  end

  # GET /affiliations/new
  def new
    @affiliation = Affiliation.new
    respond_to do |format|
      format.html
      format.js 
    end
  end

  def create
    @affiliation = Affiliation.new(params[:affiliation])

    if @affiliation.save
      flash[:notice] = 'Affiliation was successfully created.'
    end

    respond_with @affiliation
  end

  def destroy
    @affiliation.destroy
    flash[:notice] = 'Affiliation was successfully destroyed.'
    redirect_to 'index'
  end

  private ###########################################

  def get_affiliation
    @affiliation = Affiliation.find(params[:id])
  end
end
