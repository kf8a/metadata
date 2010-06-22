class TemplatesController < ApplicationController
  
  before_filter :login_required if ENV["RAILS_ENV"] == 'production'
  
  def index
    @templates = Template.find(:all)
  end
  
  def show
    @template = Template.find(params[:id])
  end
  
  def new
  end
  
  def create
  end
  
  def update
  end
  
  def delete
  end
end
