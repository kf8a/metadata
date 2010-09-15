class PermissionRequestsController < ApplicationController

  before_filter :authenticate
  
  def new
    @permission_request = PermissionRequest.new
    @datatable = Datatable.find(params[:datatable])
    @permission_request.datatable_id = @datatable
    @permission_request.user_id = current_user
  end
end
