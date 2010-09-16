class PermissionRequestsController < ApplicationController

  before_filter :authenticate
  helper :datatables
  
  def new
    @datatable = Datatable.find(params[:datatable])
  end
  
  def create
    user = current_user
    @datatable = Datatable.find(params[:datatable])
    flash[:notice] = 'Invalid user' unless user
    permission_request = PermissionRequest.new(:user => user, :datatable => @datatable)
    respond_to do |format|
      if permission_request.save
        format.html { render :action => "create" }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => permission_request.errors.to_xml }
      end
    end
  end
end
