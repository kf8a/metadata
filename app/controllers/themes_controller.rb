class ThemesController < ApplicationController
  
  before_filter :admin?, :except => [:index, :show]  if Rails.env == 'production'
  
  def index
    @theme_roots = Theme.roots    
  end
  
  def create
    @theme = Theme.create(params[:theme])
    respond_to do |format|
      if @theme.save
        flash[:notice] = 'Theme was successfully created.'
        format.html { redirect_to themes_url }
#        format.xml  { head :created, :location => theme_url(@theme) }
      else
        format.html { render :action => "index" }
        format.xml  { render :xml => @theme.errors.to_xml }
      end
    end
  end
  
  def update
    render :nothing
  end
end
