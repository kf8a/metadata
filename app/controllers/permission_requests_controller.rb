class PermissionRequestsController < ApplicationController

  before_filter :authenticate
  
  def new
    @permission_request = PermissionRequest.new
    @datatable = Datatable.find(params[:datatable])
    @permission_request.datatable_id = @datatable
    @permission_request.user_id = current_user
  end
  
  def create
    @permission_request = PermissionRequest.new(params[:permission_request])
    @datatable = @permission_request.datatable
    @permission_request.save or (render_subdomain "new" and return)
  end
end
