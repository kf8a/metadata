class PermissionRequestsController < ApplicationController

  before_filter :authenticate
  
  def new
    @permission_request = PermissionRequest.new
    @datatable = Datatable.find(params[:datatable])
  end
end
