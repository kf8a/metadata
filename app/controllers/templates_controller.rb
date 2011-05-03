class TemplatesController < ApplicationController

  before_filter :admin?, :except => [:index, :show]  if Rails.env == 'production'
  respond_to :html, :xml, :json
  
  def index
    @templates = Template.find(:all)
  end
  
  def show
    @template = Template.find(params[:id])
  end
  
  def new
    @template = Template.new
  end
  
  def create
    respond_with(@template = Template.create(params[:template]))
  end
  
  def update
  end
  
  def delete
  end
end
