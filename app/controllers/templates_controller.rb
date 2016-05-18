# TODO: do we need to keep this
class TemplatesController < ApplicationController

  before_filter :admin?, except: [:index, :show]  if Rails.env == 'production'
  respond_to :html, :xml, :json

  def index
    @templates = Template.all
  end

  def show
    @template = Template.find(params[:id])
  end

  def new
    @template = Template.new
  end

  def create
    respond_with(@template = Template.create(template_params))
  end

  def update
  end

  def delete
  end

  private

  def template_params
    params.require(:template).permit(:website_id, :controller, :action, :layout)
  end
end
