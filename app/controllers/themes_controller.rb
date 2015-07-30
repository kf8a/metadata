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
    if theme.root?
      render :partial => 'theme_list', :locals => {:theme_roots => Theme.roots}
    else
      render :partial => 'theme', :locals => {:theme => father}
    end
  end

  def create
    @theme = Theme.create(theme_params)
    respond_to do |format|
      if @theme.save
        flash[:notice] = 'Theme was successfully created.'
        format.html { redirect_to themes_url }
      else
        format.html { render "index" }
        format.xml  { render :xml => @theme.errors.to_xml }
      end
    end
  end

  def update
    theme = Theme.find(params[:id])
    if theme.update_attributes(theme_params)
      flash[:notice] = 'Theme was successfully updated.'
    end
    redirect_to themes_url
  end

  def edit
    @theme = Theme.find(params[:id])
  end

  private
  def theme_params
    params.require(:theme).permit(:name, :weight)
  end
end
