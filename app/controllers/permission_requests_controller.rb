class PermissionRequestsController < ApplicationController

  before_filter :authorize

  respond_to :js

  def create
    user = current_user
    @datatable = Datatable.find(params[:datatable])
    flash[:notice] = 'Invalid user' unless user
    permission_request = PermissionRequest.new(:user => user, :datatable => @datatable)
    permission_request.save
    render :nothing => true
  end
end
