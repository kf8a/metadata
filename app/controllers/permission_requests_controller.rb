class PermissionRequestsController < ApplicationController

  before_filter :authenticate
  
  def new
    @datatable = Datatable.find(params[:datatable])
  end
end
