class TemplatesController < ApplicationController
  
  before_filter :admin?, :except => [:index, :show]  if Rails.env == 'production'
  
  def index
    @templates = Template.find(:all)
  end
  
  def show
    @t = Template.find(params[:id])
  end
  
  def new
    @t = Template.new
  end
  
  def create
    @t = Template.new(params[:template])
    if @t.save
      redirect_to template_url(@t)
    else
      render :action => 'new'
    end
  end
  
  def update
  end
  
  def delete
  end
end
