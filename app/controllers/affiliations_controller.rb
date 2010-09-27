class AffiliationsController < ApplicationController

  before_filter :admin?, :except => [:index, :show] unless ENV["RAILS_ENV"] == 'development'
  before_filter :get_affiliation, :only => [:edit, :show, :destroy]

  def index
    @affiliations = Affiliation.all
  end
  
  def show
  end
  
  def edit
  end

  # GET /affiliations/new
  def new
    @affiliation = Affiliation.new
    respond_to do |format|
      format.html
      format.js do
        render :update do |page|
          page.insert_html :bottom, 'affiliations', :partial => "new"
        end
      end
    end
  end

  def create
    @affiliation = Affiliation.new(params[:affiliation])

    if @affiliation.save
      flash[:notice] = 'Affiliation was successfully created.'
      redirect_to @affiliation
    else
      render_subdomain "new"
    end
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