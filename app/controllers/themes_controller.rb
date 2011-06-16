class ThemesController < ApplicationController

  before_filter :admin?, :except => [:index, :show]  if Rails.env == 'production'

  def index
    @theme_roots = Theme.roots
  end

  def move_to
    theme = Theme.find(params[:parent_id])
    child = Theme.find(params[:id])
    child.move_to_child_of(theme) unless child == theme
    render :partial =>'theme', :locals => {:theme => theme}
  end

  def move_before
    theme = Theme.find(params[:parent_id])
    child = Theme.find(params[:id])
    father = theme.parent
    child.move_to_left_of(theme) unless child == theme
    render :partial => 'theme', :locals => {:area => father}
  end

  def create
    @theme = Theme.create(params[:theme])
    respond_to do |format|
      if @theme.save
        flash[:notice] = 'Theme was successfully created.'
        format.html { redirect_to themes_url }
#        format.xml  { head :created, :location => theme_url(@theme) }
      else
        format.html { render "index" }
        format.xml  { render :xml => @theme.errors.to_xml }
      end
    end
  end

  def update
    render :nothing
  end
end
