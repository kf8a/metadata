# TODO: do we need to keep this
# a controller to manage templates that skin the system
# we have not used this at all
class TemplatesController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :admin?, except: %i[index show]
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
